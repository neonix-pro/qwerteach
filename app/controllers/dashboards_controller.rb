class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user
    @future_lessons = []
    current_user.lessons_given.where(:status => 2).where('time_start > ?', DateTime.now).each { |l| @future_lessons.push l }
    current_user.lessons_received.where(:status => 2).where('time_start > ?', DateTime.now).each { |l| @future_lessons.push l }

    @pending_lessons = []
    current_user.lessons_given.where(:status => 0..1).where('time_start > ?', DateTime.now).each { |l| @pending_lessons.push l }
    current_user.lessons_received.where(:status => 0..1).where('time_start > ?', DateTime.now).each { |l| @pending_lessons.push l }

    @pending_postpayments = []
    current_user.lessons_given.each do |lesson|
      lesson.payments.where(:status => 0, :payment_type => 1).each { |l| @pending_postpayments.push l }
    end
    current_user.lessons_received.each do |lesson|
      lesson.payments.where(:status => 0, :payment_type => 1).each { |l| @pending_postpayments.push l }
    end

    @pending_prepayments = []
    current_user.lessons_given.each do |lesson|
      lesson.payments.where(:status => 0, :payment_type => 0).each { |l| @pending_prepayments.push l }
    end
    current_user.lessons_received.each do |lesson|
      lesson.payments.where(:status => 0, :payment_type => 0).each { |l| @pending_prepayments.push l }
    end

    @wallet_normal = @user.wallets.first
    @wallet_bonus = @user.wallets.second
    @wallet_transfer = @user.wallets.last
  end
end
