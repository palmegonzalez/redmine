Redmine::Plugin.register :redmine_customizable_pdf do
  name 'Redmine Customizable PDF plugin'
  author 'Ezequiel A. González | CeSPI'
  description 'This plugin allows you to customize the PDF of the issues'
  version '0.0.1'
  url ''
  author_url 'mailto:desarrollo@cespi.unlp.edu.ar'

  settings(default: { 'disabled_notes' => false, 'disabled_details' => false },
           partial: 'settings/redmine_customizable_pdf_settings')
end

Rails.configuration.to_prepare do
  # Load patches for Redmine
  require_dependency File.join(File.dirname(File.realpath(__FILE__)), 'lib', 'redmine', 'export', 'pdf', 'issues_pdf_helper')
  require_dependency File.join(File.dirname(File.realpath(__FILE__)), 'lib', 'redmine', 'export', 'pdf')

  require_dependency File.join(File.dirname(File.realpath(__FILE__)), 'lib', 'redmine', 'helpers', 'gantt')
end
