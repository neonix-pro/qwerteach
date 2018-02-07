class GlobalRequestNotificator
  include ActionView::Helpers::UrlHelper

  attr_reader :global_request, :params

  delegate :global_requests_path, to: :routes

  def initialize(global_request, params = {})
    @global_request = global_request
    @params = params
    @topic = @global_request.topic
    @level = @global_request.level
    @student = @global_request.student
  end

  def notify_teachers_about_global_request
    @teachers = Teacher.where(id: Offer.joins(:offer_prices).where(topic: @global_request.topic, offer_prices:{level: @global_request.level}).map{|o| o.user_id})
    @teachers.each do |teacher|
      NotificationsMailer.notify_teacher_about_global_request(teacher, @global_request.id).deliver_later
      notify_teacher("#{@student.name} cherche un professeur! Votre profil pourrait l'intéresser." + link_to('Détails', global_requests_path))
    end
  end


  private

  def notify_teacher(text)
    #teacher.send_notification(text, '#', student, global_request)
  end

  def routes
    Rails.application.routes.url_helpers
  end

end