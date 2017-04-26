class ToolboxController < ApplicationController

  def index

  end

  def show
    render template: "toolbox/#{params[:id]}"
  end
end