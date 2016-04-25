class ReviewsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @reviews = @user.reviews_received
    @notes = @reviews.map { |r| r.note }
    @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
  end

  def new

  end

  def create
    old =Review.where(:sender_id => current_user.id, :subject_id => params[:user_id])
    if old.empty?
      @review = Review.new(review_params)
      respond_to do |format|
        if @review.save
          format.html { redirect_to user_path(User.find(params[:user_id])), notice: 'Review was successfully created.' }
        else
          format.html { redirect_to user_path(User.find(params[:user_id])), notice: 'Review was not created.' }
        end
      end
    else
      old.first.update(review_params)
      respond_to do |format|
        if old.first.save
          format.html { redirect_to user_path(User.find(params[:user_id])), notice: 'Review was successfully updated.' }
        else
          format.html { redirect_to user_path(User.find(params[:user_id])), notice: 'Review was not updated.' }
        end
      end
    end
  end

  private
  def review_params
    params.permit(:sender_id, :subject_id, :review_text, :note).merge(sender_id: current_user.id, subject_id: params[:user_id])
  end
end
