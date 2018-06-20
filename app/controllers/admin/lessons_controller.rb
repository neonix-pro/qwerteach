module Admin
  class LessonsController < ApplicationController

    def index
      @all_students = Student.joins(:lessons_received).merge(Lesson.created.this_month).where("lessons.price > 0").distinct
      @all_teachers = Teacher.joins(:lessons_given).merge(Lesson.created.this_month).where("lessons.price > 0").distinct
      @old_students = Student.joins(:lessons_received).merge(Lesson.created.not_this_month).where("lessons.price > 0").distinct
      @old_teachers = Teacher.joins(:lessons_given).merge(Lesson.created.not_this_month).where("lessons.price > 0").distinct

      @new_students = @all_students.where.not(id: @old_students.ids)
      @new_teachers = @all_teachers.where.not(id: @old_teachers.ids)

      @amount_this_month = Lesson.locked_or_paid.this_month.sum(:price)
      @amount_total = Lesson.locked_or_paid.sum(:price)
      search = Lesson.ransack(search_params)
      resources = search.result.page(params[:page]).per(records_per_page)
      resources = order.apply(resources)
      page = Administrate::Page::Collection.new(dashboard, order: order)
      render locals: {
         resources: resources,
         search: search,
         page: page
      }
    end

    def export
      @lessons = Lesson.includes(:teacher, :student, :topic_group, :topic)
      respond_to do |format|
        format.csv { render :export }
      end
    end

    private

    def search_params
      params[:q]
    end

    def records_per_page
      20
    end

  end
end

