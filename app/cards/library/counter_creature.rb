class Library::CounterCreature < CardType
  include Instant

  def name
    "Counter creature"
  end

  def mana_cost
    Mana.new colourless: 1
  end

  def counter_creature_cost
    mana_cost
  end

  def conditions_for_counter_creature
    TextualConditions.new(
      "not targeted",
      "the stack is not empty",
      "the card on the top of the stack is a creature",
      "we can play an instant",
    )
  end

  def playing_counter_creature_goes_onto_stack?
    true
  end

  def actions_for_counter_creature
    TextualActions.new(
      "move the next card on the stack onto the graveyard",
      "move this card onto the graveyard",
    )
  end

  def self.metaverse_id
    14
  end

end
