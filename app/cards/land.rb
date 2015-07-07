module Land

  def is_land?
    true
  end

  def play_cost(game_engine, hand, target = nil)
    mana_cost
  end

  # ignoring mana costs
  def can_play?
    TextualConditions.new(
      "not targeted",
      WeHaveMana.new(mana_cost),
      "we have priority",
      "it is our turn",
      "we can play cards",
      "we have not played a land this turn",
    )
  end

  # 305.1  Playing a land is a special action; it doesn’t use the stack (see rule 115)
  def playing_play_goes_onto_stack?
    false
  end

  # ability mana cost has already been consumed
  def do_play
    TextualActions.new(
      "move this card into the battlefield",
    )
  end

  def can_tap?
    TextualConditions.new(
      "not targeted",
      "we have priority",
      "this card can be tapped",
    )
  end

  def playing_tap_goes_onto_stack?
    false
  end

  def tap_cost(game_engine, battlefield, target = nil)
    Mana.new
  end

  def do_tap
    TextualActions.new(
      "tap this card",
      AddMana.new(mana_provided)
    )
  end

  def can_untap?
    TextualConditions.new(
      "not targeted",
      "never"
    )
  end

  def playing_untap_goes_onto_stack?
    false
  end

  def untap_cost(game_engine, battlefield, target = nil)
    Mana.new
  end

  def do_untap
    TextualActions.new(
      "untap this card",
    )
  end

end
