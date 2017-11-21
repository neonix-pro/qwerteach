module ReportsHelper

  def self.build_static_sql_table(column_name, values)
    Arel.sql("(#{
      values.map { |value| "SELECT #{sqlite? ? ReportEntity.connection.quote(value).sub(/\.0+/, '') : "'#{value}'"} AS #{column_name}" }
      .join(' UNION ')
    })")
  end

  def self.sqlite?
    ActiveRecord::Base.connection.adapter_name == 'SQLite'
  end

  def available_gradations
    ReportsHelper.sqlite? ? %i[monthly daily] : LessonsReport::GRADATIONS
  end

end