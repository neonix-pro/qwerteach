class Api::ProfilesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
  end
  
  def show
    id = params[:user]["id"]
    user = User.find_by(id: id)
    if user.nil?
      warden.custom_failure!
      render :json => {:success => "false"}
    else
      render :json => {:success => "true", :user => user.as_json}
    end
  end
  
  def save
    id = params[:user]["id"]
    user = User.find_by(id: id)
    if user.nil?
      warden.custom_failure!
      render :json => {:success => "false"}
    else
      user.update firstname: params[:user]["firstname"]
      user.update lastname: params[:user]["lastname"]
      user.update description: params[:user]["description"]
      user.update birthdate: params[:user]["birthdate"]
      user.update email: params[:user]["email"]
      user.update phonenumber: params[:user]["phonenumber"]
      render :json => {:success => "true", :user => user.as_json}
    end
  end
  
  def find_level
    topic_group_level_code = "scolaire"
    level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:level => level.as_json}
  end
  
end
