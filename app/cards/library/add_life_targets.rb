class Library::AddLifeTargets < CardType
  include Instant

  def name
    "Permanently add life to creature or player"
  end

  def mana_cost
    Mana.new colourless: 1
  end

  def instant_player_cost
    mana_cost
  end

  # ignoring mana costs
  def conditions_for_instant_player
    TextualConditions.new(
      "target is a player",
      "we can play an instant",
    )
  end

  def playing_instant_player_goes_onto_stack?
    true
  end

  def actions_for_instant_player
    TextualActions.new(
      "add 1 life to the target player",
      "move this card onto the graveyard"
    )
  end

  def instant_creature_cost
    mana_cost
  end

  # ignoring mana costs
  def conditions_for_instant_creature
    TextualConditions.new(
      "target is a card",
      "target is in their battlefield",
      "target card is a creature",
      "we can play an instant",
    )
  end

  def playing_instant_creature_goes_onto_stack?
    true
  end

  def actions_for_instant_creature
    TextualActions.new(
      AddEffectToTheTargetBattlefieldCreature.new(Effects::AddOneToughness),
      "move this card onto the graveyard"
    )
  end

  def self.metaverse_id
    8
  end

end
