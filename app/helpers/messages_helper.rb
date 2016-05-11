module MessagesHelper
  def recipients_options
    s = ''
    @users = User.all - [current_user]
    @users.each do |user|
      s << "<option value='#{user.id}'>#{user.email}</option>"
    end
    s.html_safe
  end
end
