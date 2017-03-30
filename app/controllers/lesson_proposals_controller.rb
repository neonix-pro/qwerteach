class LessonProposalsController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_mangopay_account
  before_filter :user_time_zone
  before_filter :set_additional_models, only: [:new]

  def new
    @proposal = SuggestLesson.new
  end

  def create
    @proposal = SuggestLesson.run(proposal_params.merge(user: current_user))
    if @proposal.valid?
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
                                      .where.not(id: current_user.id)

    @payments = Payment.select('lessons.student_id').paid.joins(:lesson)
                    .where(lessons: {student_id: @students.map(&:id)})
                    .each_with_object({}){|p, st| st[p.student_id] = true}
  end

  def proposal_params
    params[:proposal].permit!
  end


end