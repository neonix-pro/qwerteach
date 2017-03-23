TestValidInteraction = Class.new(ActiveInteraction::Base) do
  object :res, class: Class, default: nil

  def execute
    res
  end
end

TestInvalidInteraction = Class.new(ActiveInteraction::Base) do
  def execute
    errors.add :base, 'Some Error'
  end

end