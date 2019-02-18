module StrategicPlan
  module Patches

    module CustomFieldPatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable

          safe_attributes 'search_endpoint', 'get_endpoint', 'token'
        end
      end
    end
  end
end

unless CustomField.included_modules.include?(StrategicPlan::Patches::CustomFieldPatch)
  CustomField.send(:include, StrategicPlan::Patches::CustomFieldPatch)
end