require 'redmine'

Redmine::Plugin.register :strategic_plan do
  name 'Strategic Plan plugin'
  author 'Ezequiel Gonzalez, Rosario Santa Marina | CeSPI'
  description 'This plugin adds a custom field for RestAPI'
  version '0.0.1'
  url ''
end

Rails.configuration.to_prepare do
  # Load patches for Redmine
  require_dependency File.join(File.dirname(File.realpath(__FILE__)), 'lib', 'redmine', 'field_format', 'rest_api')
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'strategic_plan', 'patches', 'custom_field_patch' )
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'strategic_plan', 'patches', 'labelled_form_builder_patch' )
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'strategic_plan', 'patches', 'issue_patch' )
  require_dependency File.join(File.dirname(File.realpath(__FILE__)), 'lib', 'redmine', 'helpers', 'gantt')
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'lib', 'strategic_plan', 'hooks', 'views_layouts_hooks' )

end