module MessagesHelper
  def recipients_options
    s = ''
    @users = User.all - [current_user]
    @users.each do |user|
      s << "<option value='#{user.id}'>#{user.email}</option>"
    end
    s.html_safe
  end

  def message_date date
    if date.today?
      return date.strftime('%H:%M')
    else
      return date.strftime('le %d/%m à %H:%M')
    end
  end
end
