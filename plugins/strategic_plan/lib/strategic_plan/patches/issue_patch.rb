require_dependency 'issue'

module StrategicPlan
  module Patches

    module IssuePatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method_chain :recalculate_attributes_for, :permanent_management
        end
      end

      module InstanceMethods
        def recalculate_attributes_for_with_permanent_management(issue_id)
          if issue_id && p = Issue.find_by_id(issue_id)
            if p.priority_derived?
              # priority = highest priority of open children
              # priority is left unchanged if all children are closed and there's no default priority defined
              if priority_position = p.children.open.joins(:priority).maximum("#{IssuePriority.table_name}.position")
                p.priority = IssuePriority.find_by_position(priority_position)
              elsif default_priority = IssuePriority.default
                p.priority = default_priority
              end
            end

            if p.dates_derived?
              # start/due dates = lowest/highest dates of children
              p.start_date = p.children.minimum(:start_date)
              p.due_date = p.children.maximum(:due_date)
              if p.start_date && p.due_date && p.due_date < p.start_date
                p.start_date, p.due_date = p.due_date, p.start_date
              end
            end

            if p.done_ratio_derived?
              # done ratio = average ratio of children weighted with their total estimated hours
              unless Issue.use_status_for_done_ratio? && p.status && p.status.default_done_ratio
                children = p.children.to_a
                children = children.reject  {|child| child.status.name == "En gestión permanente"}
                if children.any?
                  child_with_total_estimated_hours = children.select {|c| c.total_estimated_hours.to_f > 0.0}
                  if child_with_total_estimated_hours.any?
                    average = child_with_total_estimated_hours.map(&:total_estimated_hours).sum.to_f / child_with_total_estimated_hours.count
                  else
                    average = 1.0
                  end
                  done = children.map {|c|
                    estimated = c.total_estimated_hours.to_f
                    estimated = average unless estimated > 0.0
                    ratio = c.closed? ? 100 : (c.done_ratio || 0)
                    estimated * ratio
                  }.sum
                  progress = done / (average * children.count)
                  p.done_ratio = progress.round
                end
              end
            end

            # ancestors will be recursively updated
            p.save(:validate => false)
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(StrategicPlan::Patches::IssuePatch)
  Issue.send(:include, StrategicPlan::Patches::IssuePatch)
end