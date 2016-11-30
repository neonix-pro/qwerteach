class Api::RegistrationsController < Devise::RegistrationsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    super do
      if resource.save
        render :status => 200, :json => {:success => "true", :info => "Registered", :data => {:user => resource}}
        return
      else
        render :status => :unprocessable_entity, :json => {:success => "false", :info => resource.errors, :data => {}}
        return
      end
    end
  end
  
end
