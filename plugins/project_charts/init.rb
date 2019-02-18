Redmine::Plugin.register :project_charts do
  name 'Charts Plugin plugin'
  author 'Rosario Santa Marina'
  description 'This is a plugin for Redmine that show different charts using Highcharts'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'


  permission :charts, { :charts => [:index] }, :public => true
  menu :project_menu,
       :charts,
       { :controller => 'charts', :action => 'index' },
       :caption => :label_charts,
       :after => :activity,
       :param => :project_id,
       :if => ->(project) { Project.where(parent_id: nil).map {|e| e.children.map(&:name)}.flatten.include? project.name }
end

Rails.configuration.to_prepare do
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'project_charts', 'hooks', 'views_layouts_hooks' )
end