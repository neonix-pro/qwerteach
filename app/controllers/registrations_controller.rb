class RegistrationsController < Devise::RegistrationsController
  after_action :save_user_timezone, only: [:create]

  #signup as teacher
  def create
    super do
      if params[:user][:registration_type] == 'teacher'
        resource.type = User::ACCOUNT_TYPES[1]
        resource.save
      end
    end
  end

  private

  def save_user_timezone
    return unless resource.persisted?
    resource.update(time_zone: cookies[:time_zone])
  end
  def after_sign_up_path_for(resource)
    if resource.type == "Teacher"
      become_teacher_path(:general_infos)
    else
      dashboard_path
    end
  end
end