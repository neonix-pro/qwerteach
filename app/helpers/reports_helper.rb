module ReportsHelper

  def self.build_static_sql_table(column_name, values)
    Arel.sql("(#{
      values.map { |value| "SELECT '#{value}' AS #{column_name}" }
      .join(' UNION ')
    })")
  end

end