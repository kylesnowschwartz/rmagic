# TODO make the '1' value a parameter when initializing
# TODO add tests for these parameter loadings
class Add1LifeToTheOwnerOfThisCard < Action

  def execute(game_engine, stack)
    stack.player.add_life! 1
  end

end
