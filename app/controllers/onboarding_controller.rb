class OnboardingController < ApplicationController
  include Wicked::Wizard

  steps :welcome, :choose_role, :phone #,:topics

  def show
    @user = current_user
    case step
      when :welcome
        skip_step
      when :picture
      when :topics
        @topic_groups = TopicGroup.first(6)
        @teachers = Teacher.order(score: :desc).first(8)
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
      when :picture
        @user.update_attributes(user_params)
      when :phone
        @user.update_attributes(user_params)
    end
    render_wizard @user
  end

  private
  def user_params
    params.require(:user).permit(:crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname,
                                 :description, :avatar, :phone_number, :phone_country_code)
  end
end