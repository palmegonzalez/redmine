require 'rest-client'
require 'uri'
require 'integrator/extern_people'

module Redmine
  module RestRequests
    def self.as_select2(custom_value)
      self.get(custom_value.custom_field, custom_value.value).reject(&:blank?).map do | each |
      	{
          'id': each["id"],
          'text': self.text(each)
        }
      end.to_json.html_safe
    end

    def self.as_formatted_value(custom_field, value, html)
      if html
        res = self.get(custom_field, value).map do | each |
          "<li>#{self.text(each)}</li>"
        end.join
        "<ul style='list-style-type: none; padding: 0;margin-top: 0;'>#{res}</ul>".html_safe
      else
        res = self.get(custom_field, value).map do | each |
          self.text(each)
        end.join(', ')
      end
    end

    #FIX: Change this method when IntegratorWrapper gem is done
    def self.get(custom_field, value)
      url = "#{custom_field.get_endpoint}?token=#{custom_field.token}"

      value.compact.map do |each|
        if each.start_with?("0")
          JSON.parse(RestClient.get(url.gsub ':id', each))
        else
          Integrator::ExternPeople::Person.where(q: each).first
        end
      end
    end

    #FIX: Change this method when IntegratorWrapper gem is done
    def self.text(data)
      unless data.nil?
        id = data["id"]
        if id.start_with?("0")
          first_name = data["first_name"]
          last_name  = data["last_name"]
          identifier = data["cuil"] || data["document_number"]
          [first_name, last_name, '-', identifier].join(" ")
        else
          extern_text(data)
        end
      end
    end

    #FIX: Delete this method when IntegratorWrapper gem is done
    def self.extern_text(person)
      first_name = person.firstname
      last_name  = person.lastname
      identifier = person.cuil || person.document_number
      [first_name, last_name, '-', identifier].join(" ")
    end

    #FIX: Change this method when IntegratorWrapper gem is done
    def self.search(custom_field, q)
      url = "#{custom_field.search_endpoint}?token=#{custom_field.token}"
      integrator_people = JSON.parse(RestClient.get(URI.escape(url.gsub(':query', q)))).map do |each|
      	{ id: each['id'], text: text(each) }
      end

      extern_people = Integrator::ExternPeople::Person.where(q: q).map do |each|
        {id: each.document_number.to_s, text: extern_text(each)}
      end

      integrator_people + extern_people
    end
  end
end