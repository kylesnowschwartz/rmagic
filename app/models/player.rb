class Player < ActiveRecord::Base
  include SafeJson
  include Subscribable

  has_many :deck, -> { order(order: :desc) }, dependent: :destroy
  has_many :hand, dependent: :destroy
  has_many :battlefield, dependent: :destroy
  has_many :graveyard, -> { order(order: :desc) }, dependent: :destroy

  has_one :user

  validates :life, :name, :mana_blue, :mana_green,
      :mana_red, :mana_white, :mana_black,
      :mana_colourless, presence: true

  before_validation :init

  def init
    self.life ||= 20
    self.name ||= "Player"
    self.is_ai ||= false
    self.mana_blue ||= 0
    self.mana_green ||= 0
    self.mana_red ||= 0
    self.mana_white ||= 0
    self.mana_black ||= 0
    self.mana_colourless ||= 0
  end

  def zones
    [ deck, hand, battlefield, graveyard ]
  end

  def mana
    mana_pool.to_s
  end

  def clear_mana!
    set_mana! Mana.new
  end

  def set_mana!(mana)
    update!({
      mana_green: mana.green,
      mana_blue: mana.blue,
      mana_red: mana.red,
      mana_white: mana.white,
      mana_black: mana.black,
      mana_colourless: mana.colourless
    })
  end

  def mana_pool
    Mana.new({
      green: mana_green,
      blue: mana_blue,
      red: mana_red,
      white: mana_red,
      black: mana_black,
      colourless: mana_colourless
    })
  end

  def has_mana?(cost)
    mana_pool.use(cost).present?
  end

  def use_mana!(cost)
    result = mana_pool.use(cost)
    fail "Could not use mana #{cost} from #{pool}" unless result

    set_mana! result
  end

  def add_mana!(cost)
    result = mana_pool.add(cost)

    set_mana! result
  end

  def add_life!(n)
    update! life: life + n
  end

  def remove_life!(n)
    update! life: life - n
  end

  def battlefield_creatures
    select_creatures battlefield
  end

  def battlefield_lands
    select_lands battlefield
  end

  def hand_creatures
    select_creatures hand
  end

  def hand_lands
    select_lands hand
  end

  def graveyard_creatures
    select_creatures graveyard
  end

  def graveyard_lands
    select_lands graveyard
  end

  def select_creatures(collection)
    collection.select { |b| b.card.card_type.is_creature? }
  end

  def select_lands(collection)
    collection.select { |b| b.card.card_type.is_land? }
  end

  def next_graveyard_order
    return 1 if graveyard.empty?
    graveyard.map(&:order).max + 1
  end

  def next_deck_order
    return 1 if deck.empty?
    deck.map(&:order).max + 1
  end

  def is_card?
    false
  end

  def is_player?
    true
  end

  def to_text
    "Player #{name}"
  end

  def has_zone?
    false
  end

  def duel
    Duel.where("player1_id=? OR player2_id=?", id, id).first!
  end

  # TODO should maybe be self.safe_json_attributes
  # TODO maybe safe_json should be to_safe_json
  def safe_json_attributes
    [ :id, :name, :mana, :life ]
  end

  # TODO should maybe be self.extra_json_attributes
  def extra_json_attributes
    {
      mana: mana_pool.to_hash,
      mana_string: mana
    }
  end

  def all_actions_json
    {
      play: action_finder.playable_cards(self).map(&:safe_json),
      ability: action_finder.ability_cards(self).map(&:safe_json),
      defend: action_finder.defendable_cards(self).map(&:safe_json),
      attack: action_finder.available_attackers(self).map(&:safe_json),
      game: action_finder.game_actions(self).map(&:safe_json)
    }
  end

  after_update :update_player_channels

  def update_action_channels
    channel = get_channel("actions/#{id}")
    if channel.needs_update?
      channel.update all_actions_json
    end
  end

  def update_player_channels
    UpdatePlayerChannels.new(duel: duel).call
  end

  private

    def action_finder
      @action_finder ||= ActionFinder.new(duel)
    end

    # maybe:

    # 1.
    # create_channel "graveyard", :id, :graveyard_json
    # has_json :hand

    # 2.
    # json_channel :graveyard, :id

    # 3.
    # --> safe_json_channel :graveyard, :id

    # or should this be through a separate object/service?

    # DuelJsonPresenter < JsonPresenter
    #   json_presenter_for :duel
    #   ...

    # or separate Channel controllers?

    # 4.
    # /app/channels/deck_channel.rb

    # class DeckChannel < Channel
    #   json_channel :graveyard, :id

end

# class DeckChannels < Channels
#   safe_json_channel :graveyard, :id

#   json_channel :actions, :id, :all_actions_json
# end

# class DeckPresenter < Presenter
#   attr_reader :deck

#   def graveyard
#     {
#       # graveyard: deck.graveyard.map(&:to_safe_json)
#       graveyard: deck.graveyard.map { |g| ZonecardPresenter.new(g) }.map(&:to_safe_json)
#     }
#   end
# end

# def PlayerChannels
#   attr_reader :player

#   # creates a "graveyard/#{id}" channel
#   # and uses the PlayerPresenter(player).graveyard_json presenter
#   json_channel :graveyard, :id
# end

# def PlayerPresenter
#   def graveyard_json
#     {
#       # graveyard: deck.graveyard.map(&:to_safe_json)
#       graveyard: deck.graveyard.map { |g| ZonecardPresenter.new(g) }.map(&:to_safe_json)
#     }
#   end
# end
