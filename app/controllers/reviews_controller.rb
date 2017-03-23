class ReviewsController < ApplicationController
  before_filter :authenticate_user! unless :featured_reviews

  def index
    @user = User.find(params[:user_id])
    @reviews = @user.reviews_received
    @notes = @reviews.map { |r| r.note }
    @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
  end

  def new
    @review = Review.new(new_review_params)
  end

  def create
    old =Review.where(:sender_id => current_user.id, :subject_id => params[:user_id])
    if old.empty?
      @review = Review.new(review_params)
      respond_to do |format|
        if @review.save
          format.html { redirect_to user_path(User.find(params[:user_id])), notice: t('review.creation.success') }
          format.json {render :json => {:success => "true", :message => t('review.creation.success')}}
        else
          flash[:danger]=t('review.creation.error', message: @review.errors.full_messages.to_sentence)
          format.html { redirect_to user_path(User.find(params[:user_id])) }
          format.json {render :json => {:success => "false", 
            :message => t('review.creation.error', message: @review.errors.full_messages.to_sentence)}}
        end
      end
    else
      old.first.update(review_params)
      respond_to do |format|
        if old.first.save
          format.html { redirect_to user_path(User.find(params[:user_id])),notice: t('review.update.success') }
          format.json {render :json => {:success => "true"}}
        else
          flash[:danger]=t('review.update.error', message: @review.errors.full_messages.to_sentence)
          format.html { redirect_to user_path(User.find(params[:user_id]))}
          format.json {render :json => {:success => "false"}}
        end
      end
    end
  end

  def featured_reviews
    @n = params[:n]
    @offset = params[:offset]
    @reviews = Review.where('note >=  4 AND review_text IS NOT NULL AND review_text != "" ').limit(@n).offset(@offset)
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
  private
  def new_review_params
    params.permit(:sender_id, :subject_id, :note, :review_text).merge(sender_id: current_user.id, subject_id: params[:user_id])
  end
  def review_params
    params.require(:review).permit(:sender_id, :subject_id, :note, :review_text).merge(sender_id: current_user.id, subject_id: params[:user_id])
  end
end
