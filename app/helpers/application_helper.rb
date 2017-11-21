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
  
  def resource_class
    devise_mapping.to
  end

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  # TODO: replace avatar.jpg with no avatar image
  def avatar_url(user, style = :small)
    user.avatar.present? ? user.avatar.url(style) : image_path('avatar.jpg')
  end
end


