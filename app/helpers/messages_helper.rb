module MessagesHelper

  def recipients_options
    @users = User.where.not(id: current_user.id)
    @users.map{|u| content_tag 'option', u.email, value: u.id }.join.html_safe
  end

  def message_date date
    if date.today?
      return date.strftime('%H:%M')
    else
      return date.strftime('le %d/%m à %H:%M')
    end
  end
end
