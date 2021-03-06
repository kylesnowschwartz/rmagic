module Playable

  def play_cost
    mana_cost
  end

  def conditions_for_play
    TextualConditions.new(
      "not targeted",
      "we have priority",
      "it is our turn",
      "we can play cards",
    )
  end

  # ability mana cost has already been consumed
  def actions_for_play
    TextualActions.new(
      "play this card",
    )
  end

  def playing_play_goes_onto_stack?
    true
  end

end
