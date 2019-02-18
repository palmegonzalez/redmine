
Redmine::Plugin.register :redmine_custom_email_transparencia do
  name 'Redmine Custom Email Transparencia plugin'
  author 'Ezequiel A. González | CeSPI - UNLP'
  description 'Plugin para personalizar el envio y la plantilla de los email especificamente para peticionantes del proyecto transparencia academica'
  version '0.0.1'
  url ''
  author_url ''
end

Rails.configuration.to_prepare do
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'app', 'hooks', 'issue_controller_hook')
  require_dependency File.join( File.dirname(File.realpath(__FILE__)), 'app', 'models', 'requester_mailer')
end


