module StrategicPlan
  module Patches
    module LabelledFormBuilderPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :label_for_field, :hints
        end
      end

      module InstanceMethods
        def label_for_field_with_hints(field, options = {})
  	      return ''.html_safe if options.delete(:no_label)
  	      text = options[:label].is_a?(Symbol) ? l(options[:label]) : options[:label]

  	      if field.to_s == 'status_id' || field.to_s == 'priority_id' || field.to_s == 'assigned_to_id'
  	        text ||= l(("hint_" + field.to_s.gsub(/\_id$/, "")).to_sym)
  	      else
  	        text ||= l(("field_" + field.to_s.gsub(/\_id$/, "")).to_sym)
  	      end

  	      text += @template.content_tag("span", " *", :class => "required") if options.delete(:required)
  	      @template.content_tag("label", text.html_safe,
  	                                   :class => (@object && @object.errors[field].present? ? "error" : nil),
  	                                   :for => (@object_name.to_s + "_" + field.to_s))
  	    end
      end
    end
  end
end

unless Redmine::Views::LabelledFormBuilder.included_modules.include?(StrategicPlan::Patches::LabelledFormBuilderPatch)
  Redmine::Views::LabelledFormBuilder.send(:include, StrategicPlan::Patches::LabelledFormBuilderPatch)
end