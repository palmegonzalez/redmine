module ProjectCharts
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return javascript_include_tag('highcharts', :plugin => 'project_charts') +
               javascript_include_tag('highcharts-more', :plugin => 'project_charts') +
               javascript_include_tag('exporting', :plugin => 'project_charts') +
               javascript_include_tag('export-data', :plugin => 'project_charts')

      end
    end
  end
end