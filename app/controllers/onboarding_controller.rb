class OnboardingController < ApplicationController
  include Wicked::Wizard

  steps :welcome, :choose_role, :picture, :topics

  def show
    @user = current_user
    case step
      when :welcome

    end
    render_wizard
  end

  def update
    @user = current_user
    case step
      when :welcome
    end
    render_wizard @user
  end
end