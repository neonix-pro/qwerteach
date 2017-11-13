class ApplicationReport < ActiveInteraction::Base

  def execute
    Kaminari.paginate_array(load,
      offset: offset,
      limit: limit,
      total_count: total_count
    )
  end

  private

  def load
    ReportEntity.find_by_sql(arel.to_sql)
  end

  def arel
    raise NotImplementedError, 'To be implemented in a derivative class'
  end

  def metrics
    raise NotImplementedError, 'To be implemented in a derivative class'
  end

  def add_metrics_expressions(scope)
    metrics.each_key do |metric|
      cte_table = Arel::Table.new("#{metric}_cte")
      expression = build_metric_expression(metric)
      composed_cte = Arel::Nodes::As.new(expression, cte_table)
      scope
        .project(coalence(cte_table[:value], 0).as(metric.to_s))
        .join(composed_cte, Arel::Nodes::OuterJoin).on(cte_table[:foreign_key].eq primary_key)
    end
  end

  def build_metric_expression(metric)
    params = metrics[metric]
    table = self.send(params[:from])

    foreign_column = params[:foreign_key] || default_foreign_column

    return table
      .project(
        Arel.sql(params[:expression] || 'COUNT(*)').as('value'),
        Arel.sql(foreign_column).as('foreign_key')
      )
      .group(foreign_column)
  end

  def default_foreign_column
    raise NotImplementedError, 'To be implemented in a derivative class'
  end

  def primary_key
    raise NotImplementedError, 'To be implemented in a derivative class'
  end

  def coalence(*arrts)
    Arel::Nodes::NamedFunction.new('COALESCE', arrts)
  end

  def total_count
    raise NotImplementedError, 'To be implemented in a derivative class'
  end

  def limit
    per_page
  end

  def offset
    (page - 1) * per_page
  end

end