class LessonProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_mangopay_account
  before_filter :user_time_zone
  before_filter :set_additional_models, only: [:new]

  def new
    @proposal = SuggestLesson.new
    @proposal.student_id = params[:id]
  end

  def create
    @proposal = SuggestLesson.run(proposal_params.merge(user: current_user))
    if @proposal.valid?
      tracker do |t|
        t.google_analytics :send, { type: 'event', category: "Réservation - prof", action: "Proposer un cours", label: "Prof id: #{current_user.id}"}
      end
      redirect_to dashboard_path, notice: 'Lesson was created successfully'
    else
      respond_to do |format|
        format.html do
          set_additional_models
          render :new
        end
        format.js { render :errors }
      end
    end
  end

  private

  def set_additional_models
    @students = User.where(id: current_user.mailbox.conversations
                                      .where('mailboxer_conversations.updated_at > ?', 1.year.ago)
                                      .includes(:messages).flat_map(&:messages).map(&:sender_id).uniq)
                                      .with_payments_count
                                      .where.not(id: current_user.id)
  end

  def proposal_params
    params[:proposal].permit!
  end


end