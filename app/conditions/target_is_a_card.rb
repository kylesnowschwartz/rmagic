class TargetIsACard < Condition

  def evaluate(game_engine, stack)
    stack.target != nil &&
      stack.target.is_card?
  end

end
