class LessonPacksController < ApplicationController
  include PaymentActions
  load_and_authorize_resource except: [:show]
  before_action :set_lesson_pack, only: [:show, :edit, :update, :destroy, :approve, :reject, :propose, :payment, :pay, :finish]
  helper_method :lesson_pack_params

  def show
    authorize! :show, @lesson_pack
  end

  def new
    @lesson_pack = if params[:lesson_pack].present?
      LessonPack.new(lesson_pack_params)
    else
      LessonPack.new(student_id: params[:student_id], items: Array.new(10){ LessonPackItem.new } )
    end
  end

  def confirm
    @lesson_pack = params[:id] ? LessonPack.find(params[:id]) : LessonPack.new(lesson_pack_params)
    if @lesson_pack.valid?
      render :confirm
    else
      render @lesson_pack.persisted? ? :edit : :new
    end
  end

  def edit
  end

  def create
    @lesson_pack = LessonPack.new(lesson_pack_params)

    if @lesson_pack.save
      ProposeLessonPack.run!(lesson_pack: @lesson_pack)
      redirect_to lessons_path, notice: "Le forfait de #{@lesson_pack.hours}h de cours (#{@lesson_pack.amount}€) a bien été enregistré. Nous attendons validation de l'élève."
    else
      render :new
    end
  end

  def propose
    ProposeLessonPack.run!(lesson_pack: @lesson_pack)
    redirect_to lessons_path, notice: "Le forfait de #{@lesson_pack.hours}h de cours (#{@lesson_pack.amount}€) a bien été enregistré."
  end

  def payment
    creation = Mango::CreateCardRegistration.run(user: current_user)
    if creation.valid?
      @card_registration = creation.result
    else
      redirect_to @lesson_pack, 'There are some problems with payment system. Please, contact administrator'
    end
  end

  def pay
    perform_payment
  end

  def approve
    @lesson_pack.status = LessonPack::Status::ACCEPTED
    if @lesson_pack.save
      redirect_to action: :pay, id: lesson_pack.id
    else
      redirect_to @lesson_pack, notice: 'There are some problems with pack. Please, contact administrator'
    end
  end

  def reject
    rejecting = RejectLessonPack.run(lesson_pack: @lesson_pack)
    if rejecting.valid?
      redirect_to '/', notice: "Vous avez décliné la proposition de forfait faite par #{@lesson_pack.teacher.full_name}."
    else
      redirect_to @lesson_pack, notice: 'There are some problems with pack. Please, contact administrator'
    end
  end

  def update
    if @lesson_pack.update(lesson_pack_params)
      redirect_to confirm_lesson_pack_path(@lesson_pack)
    else
      render :edit
    end
  end

  def destroy
    @lesson_pack.destroy
    redirect_to lesson_packs_url, notice: 'Le forfait a été supprimé.'
  end

  def payment_success(payment_method, transactions)
    @lesson_pack = LessonPack.find(params[:id])

    ApproveLessonPack.run!(
      lesson_pack: @lesson_pack,
      payment_method: payment_method,
      transactions: transactions)

    respond_to do |format|
      format.html { render 'finish' }
      #format.js { render 'finish' }
    end
  rescue => e
    #TODO: Exceptionally situation. Add some notifications, sentry for example
    payment_error(payment_method, e)
  end

  private

    def set_lesson_pack
      if params[:id].to_i > 0 
        @lesson_pack = LessonPack.find(params[:id])
      else
        redirect_to new_lesson_pack_path
      end
    end

    def lesson_pack_params
      params.require(:lesson_pack).permit(:id, :state, :student_id, :discount, :topic_id, :level_id,
          items_attributes: [:time_start, :hours, :minutes, :id, :_destroy]).merge('teacher_id' => current_user.id)
    end

  def bancontact_return_url
    finish_payment_lesson_pack_url(@lesson_pack.id, :bancontact)
  end

  def credit_card_return_url
    finish_payment_lesson_pack_url(@lesson_pack.id, :credit_card)
  end

  def payment_fallback_url
    payment_lesson_pack_path(@lesson_pack)
  end

  def payment_amount
    @lesson_pack.amount
  end
end
