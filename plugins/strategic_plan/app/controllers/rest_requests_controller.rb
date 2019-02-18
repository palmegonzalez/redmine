class RestRequestsController < ApplicationController
  before_action :custom_field, :only => [:search]

  def search
    render json: { results: Redmine::RestRequests.search(@custom_field, params['q']) }
  end

  private

  def custom_field
  	@custom_field = CustomField.find params['custom_field_id']
  end
end