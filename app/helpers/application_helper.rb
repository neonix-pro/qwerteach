module ApplicationHelper

  def header(text)
    content_for(:header) { text.to_s }
  end

  #make devise stuff available everywhere
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def page_header(text)
    content_for(:page_header) { text.to_s }
  end
  def avatar_for(user, size = 30, title = user.email)
    image_tag user.avatar.url(size), title: title, class: 'img-rounded'
  end
end


