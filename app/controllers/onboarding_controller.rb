class OnboardingController < ApplicationController
  include Wicked::Wizard

  steps :welcome, :choose_role, :topics

  def finish_wizard_path
    profs_path
  end

  def show
    @user = current_user
    case step
      when :welcome
        skip_step
      when :phone
        drip
      when :topics
        drip
        @drip.create_or_update_subscriber(current_user.email, {custom_fields: current_user.drip_custom_fields, user_id: current_user.id})
        #@drip.subscribe(current_user.email, '55297918', double_optin: false)
        @drip.subscribe(current_user.email, '118642767', double_optin: false)
        @global_request = GlobalRequest.new()
        @levels = []
        @topics = Topic.where.not(title: 'Autre')
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
      when :choose_role
        @user.update_attributes(user_params)
        flash[:danger] = @user.errors.full_messages unless @user.valid?
      when :topics
      when :phone
        @user.update_attributes(user_params)
    end
    render_wizard @user
  end

  private
  def user_params
    params.require(:user).permit(:crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname,
                                 :description, :avatar, :phone_number, :phone_country_code, :type)
  end
end