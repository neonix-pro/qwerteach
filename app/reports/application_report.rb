class ApplicationReport < ActiveInteraction::Base

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
    raise NotImplementedError, 'To be implemented in a derivative class'
  end

  def primary_key
    raise NotImplementedError, 'To be implemented in a derivative class'
  end


  def coalence(*arrts)
    Arel::Nodes::NamedFunction.new('COALESCE', arrts)
  end

end