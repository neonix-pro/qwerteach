module Admin
  module DashboardHelper

    def data_for_lesson_counts_chart(entities)
      entities.map do |entity|
        {
          period: l(Date.parse(entity.period), format: :short),
          count: entity.lessons_count
        }
      end
    end

    def data_for_lesson_amounts_chart(entities)
      entities.map do |entity|
        {
          period: l(Date.parse(entity.period), format: :short),
          count: entity.lessons_amount
        }
      end
    end

  end
end