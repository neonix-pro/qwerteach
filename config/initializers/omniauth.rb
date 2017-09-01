Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :twitter, "zJLgYhx0QVgh6e58EFSIhxHuL", "FTKNu4Oa9W3TH1uN5dX0svMLqNvysVhUn6T69pjRBZl2sYh6f3"
    provider :facebook, "469401469916085", "ac2048e3164091db1e4cd22d89813e5", secure_image_url: true , scope: 'email', info_fields: 'email,name,first_name,last_name,gender'
    provider :google_oauth2, "1050328477515-4cdevujj1h044kqt41fqh4dd8nf61mo8.apps.googleusercontent.com", "bG5ygVRwoep0_JJqqDvI1o6h", { access_type: "offline", approval_prompt: "" }
  elsif Rails.env.production?
    #provider :twitter, "zJLgYhx0QVgh6e58EFSIhxHuL", "FTKNu4Oa9W3TH1uN5dX0svMLqNvysVhUn6T69pjRBZl2sYh6f3"
    provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], secure_image_url: true , scope: 'email', info_fields: 'email,name,first_name,last_name,gender', image_size: {width: 400, height: 400}
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'], { access_type: "offline", approval_prompt: "", scope: "userinfo.email,userinfo.profile" }
  end
end