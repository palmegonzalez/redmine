require 'redmine'

Redmine::Plugin.register :projects_pdf_exporter do
  name 'Projects PDF Exporter plugin'
  author 'Rosario Santa Marina | CeSPI'
  description 'This plugin let the user to export to pdf a global report with its subprojects and issues'
  version '0.0.1'
  url ''
end

Rails.configuration.to_prepare do
  # Load patches for Redmine
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'projects_pdf_exporter', 'patches', 'projects_controller_patch')
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'redmine', 'export', 'pdf', 'projects_pdf_helper')

end