Redmine::Plugin.register :redmine_private_issues do
  name 'Redmine Private Issues plugin'
  author 'Rosario Santa Marina | CeSPI'
  description 'This plugin set default true the private field of all issues when is enabled'
  version '1.0.0'
  url ''
  author_url 'mailto:desarrollo@cespi.unlp.edu.ar'

  settings :default => {'enabled' => 'false'}, :partial => 'settings/redmine_private_issues_settings'
end