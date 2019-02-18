require 'rest-client'
require 'redmine/field_format'

module Redmine
  module FieldFormat
    class RestAPI < Base
      add 'restAPI'
      self.searchable_supported = false
      self.multiple_supported = true
      self.form_partial = 'custom_fields/formats/rest_api'
      field_attributes :search_endpoint, :get_endpoint, :token

      def formatted_value(view, custom_field, value, customized=nil, html=false)
        Redmine::RestRequests.as_formatted_value(custom_field, value, html)
      end

      def edit_tag(view, tag_id, tag_name, custom_value, options={})
        view.render partial: 'issues/rest_api_search', locals: {
          tag_id: tag_id,
          tag_name: tag_name,
          custom_value: custom_value,
          options: options
        }
      end
    end
  end
end
