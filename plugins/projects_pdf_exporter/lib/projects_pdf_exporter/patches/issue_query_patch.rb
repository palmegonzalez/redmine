require_dependency 'query'

module ProjectsPdfExporter
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          self.available_columns = [
            QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
            QueryColumn.new(:tracker, :sortable => "#{Tracker.table_name}.position", :groupable => true),
            QueryColumn.new(:parent, :sortable => ["#{Issue.table_name}.root_id", "#{Issue.table_name}.lft ASC"], :default_order => 'desc', :caption => :field_parent_issue),
            QueryColumn.new(:status, :sortable => "#{IssueStatus.table_name}.position", :groupable => true),
            QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true),
            QueryColumn.new(:subject, :sortable => "#{Issue.table_name}.subject"),
            QueryColumn.new(:author, :sortable => lambda {User.fields_for_order_statement("authors")}, :groupable => true),
            QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
            QueryColumn.new(:updated_on, :sortable => "#{Issue.table_name}.updated_on", :default_order => 'desc'),
            QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name", :groupable => true),
            QueryColumn.new(:fixed_version, :sortable => lambda {Version.fields_for_order_statement}, :groupable => true),
            QueryColumn.new(:start_date, :sortable => "#{Issue.table_name}.start_date"),
            QueryColumn.new(:due_date, :sortable => "#{Issue.table_name}.due_date"),
            QueryColumn.new(:estimated_hours, :sortable => "#{Issue.table_name}.estimated_hours", :totalable => true),
            QueryColumn.new(:total_estimated_hours,
              :sortable => "COALESCE((SELECT SUM(estimated_hours) FROM #{Issue.table_name} subtasks" +
                " WHERE subtasks.root_id = #{Issue.table_name}.root_id AND subtasks.lft >= #{Issue.table_name}.lft AND subtasks.rgt <= #{Issue.table_name}.rgt), 0)",
              :default_order => 'desc'),
            QueryColumn.new(:done_ratio, :sortable => "#{Issue.table_name}.done_ratio", :groupable => true),
            QueryColumn.new(:created_on, :sortable => "#{Issue.table_name}.created_on", :default_order => 'desc'),
            QueryColumn.new(:closed_on, :sortable => "#{Issue.table_name}.closed_on", :default_order => 'desc'),
            QueryColumn.new(:last_updated_by, :sortable => lambda {User.fields_for_order_statement("last_journal_user")}),
            QueryColumn.new(:relations, :caption => :label_related_issues),
            QueryColumn.new(:attachments, :caption => :label_attachment_plural),
            QueryColumn.new(:description, :inline => false),
            QueryColumn.new(:last_notes, :caption => :label_last_notes, :inline => false)

          ]

        end
      end

      module InstanceMethods
        def inline_columns
          columns.select(&:inline?).push(self.available_columns[1])
        end
      end
    end
  end
end

unless IssueQuery.included_modules.include?(ProjectsPdfExporter::Patches::IssueQueryPatch)
  IssueQuery.send(:include, ProjectsPdfExporter::Patches::IssueQueryPatch)
end