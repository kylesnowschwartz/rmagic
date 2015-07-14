class Library::DeadWeight < CardType
  include Enchantment

  def name
    "Dead Weight"
  end

  def mana_cost
    Mana.new black: 1
  end

  def ability_cost
    mana_cost
  end

  def can_ability?
    TextualConditions.new(
      "target is a card",
      "target is in their battlefield",
      "target card is a creature",
      "we can play an enchantment",
    )
  end

  def playing_ability_goes_onto_stack?
    true
  end

  def do_ability
    TextualActions.new(
      "play this card",
      "attach this card to the target",
    )
  end

  def self.metaverse_id
    220393
  end

  def modify_power(n)
    n - 2
  end

  def modify_toughness(n)
    n - 2
  end

end
