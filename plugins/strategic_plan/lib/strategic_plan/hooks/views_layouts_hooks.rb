module StrategicPlan
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return javascript_include_tag(:select2, :plugin => 'strategic_plan') +
          stylesheet_link_tag(:select2, :plugin => 'strategic_plan')
      end
    end
  end
end