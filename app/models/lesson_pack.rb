class LessonPack < ActiveRecord::Base
  module Status
    DRAFT = 0
    PENDING_STUDENT = 1
    PENDING_TEACHER = 2
    ACCEPTED = 3
    DECLINED = 4
    PAID = 5
  end

  enum status: {
    draft: Status::DRAFT,
    pending_student: Status::PENDING_STUDENT,
    pending_teacher: Status::PENDING_TEACHER,
    paid: Status::PAID,
    declined: Status::DECLINED
  }
  belongs_to :topic, required: true
  belongs_to :level, required: true
  belongs_to :teacher, required: true, :class_name => 'User', :foreign_key  => "teacher_id"
  belongs_to :student, required: true
  has_many :items, class_name: 'LessonPackItem', foreign_key: :lesson_pack_id, dependent: :destroy, inverse_of: :lesson_pack
  has_many :lessons
  has_many :payments, -> { distinct }, through: :lessons
  accepts_nested_attributes_for :items, allow_destroy: true

  validate :items_count_should_be_between_5_and_20
  validate :no_another_packs_for_student, on: :create
  validates :discount, numericality: { only_integer: true, less_than_or_equal_to: 50 }
  validate :items_should_be_in_future

  def duration
    @duration ||= items.inject(0) { |s, item| s + item.duration }
  end

  def rate
    @rate ||= Offer.joins(:offer_prices)
      .where(
        user_id: teacher_id,
        topic_id: topic_id,
        offer_prices: { level_id: level_id })
      .pluck(:price).first.to_f
  end

  def topic_title
    Offer.joins(:offer_prices)
        .where(
            user_id: teacher_id,
            topic_id: topic_id
            )
        .first.title
  end

  #prix hors discount
  def cost
    duration * rate / 60
  end

  #effectivement payé (prends en compte le discount)
  def amount
    duration * rate / 60 * (1 - (discount || 0) / 100.0)
  end

  def hours
    duration/60.0
  end

  def pending?
    status == 'pending_student' || status == 'pending_teacher'
  end

  private

  def items_count_should_be_between_5_and_20
    errors.add(:items, 'can\'t be less than 5') if items.size < 5
    errors.add(:items, 'can\'t be more than 20') if items.size > 20
  end

  def no_another_packs_for_student
    if LessonPack.pending_student.where(student_id: student_id, teacher_id: teacher_id).exists?
      errors.add(:base, "Vous ne pouvez proposer qu'un seul forfait à la fois à un même élève. Attendez sa réponse avant d'en proposer un autre.")
    end
  end

  def first_lesson_start
    items.map{|i| i.time_start}.min
  end

  def items_should_be_in_future
    if first_lesson_start < Time.now
      errors.add(:base, 'Les cours du forfait doivent être dans le futur')
    end
  end

end