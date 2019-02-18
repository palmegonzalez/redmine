class ChartsController < ApplicationController

  def index
  	@project = Project.find(params[:project_id])
  	@chart_data  = ChartsHelper.dataForBubble(@project)
  end

end