class Library::Mountain < CardType
  include Land

  def name
    "Mountain"
  end

  def mana_provided
    Mana.new red: 1
  end

  def self.metaverse_id
    383317
  end

end
