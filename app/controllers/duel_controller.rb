class DuelController < ApplicationController
  before_filter :authenticate

  def create
    # TODO move this into a service so we can test it? (GameCreationService? GameCreator?)
    player1 = current_user.players.create! name: current_user.name, life: 20, is_ai: false
    player2 = Player.create! name: "AI", life: 20, is_ai: true

    @duel = Duel.create! player1: player1, player2: player2

    # create deck
    deck1 = PremadeDeck.find(params[:deck1])
    deck2 = PremadeDeck.find(params[:deck2])

    deck1.cards.each_with_index do |c, i|
      create_order_card player1.deck, c.metaverse_id, i
    end
    deck2.cards.each_with_index do |c, i|
      create_order_card player2.deck, c.metaverse_id, i
    end

    # TODO shuffle deck
    # TODO mulligans, pre-game setup

    duel.save!      # TODO remove

    # execute the first phase of the game
    duel.phase.enter_phase_service.new(duel: duel).call

    redirect_to duel_path duel
  end

  def show
    @duel = duel
  end

  def pass
    PassPriority.new(duel: duel).call
    redirect_to duel_path duel
  end

  # TODO maybe refactor into resources e.g.
  # POST /duel/123/turn/create/[source]/[key]/[target]?
  # POST /duel/123/turn/play/[source]/[key]/[target]?
  # POST /duel/123/play/[source]/[key]/[target]?
  # e.g. GET /duel/123/player/1/battlefield.json
  #
  # POST /duel/123/player/1/hand/123/play?key="do something"
  # - this maps nicely to getting child resources through .json
  def play
    action = PossiblePlay.new(
      source: Hand.find(params[:hand]),
      key: params[:key],
      target: find_target
    )
    action.do(duel)
    redirect_to duel_path duel
  end

  def ability
    action = PossibleAbility.new(
      source: Battlefield.find(params[:battlefield]),
      key: params[:key],
      target: find_target
    )
    action.do(duel)
    redirect_to duel_path duel
  end

  def defend
    source = Battlefield.find(params[:source])
    target = DeclaredAttacker.find(params[:target])
    defender = PossibleDefender.new(
      source: source,
      target: target
    )
    defender.declare(duel)
    redirect_to duel_path duel
  end

  def declare_attackers
    if params[:attacker]
      attackers = Battlefield.find(params[:attacker])
      DeclareAttackers.new(duel: duel, zone_cards: attackers).call
    end
    duel.save!    # TODO remove
    pass
  end

  helper_method :playable_cards, :ability_cards, :defendable_cards
  helper_method :available_attackers, :get_target_type

  def playable_cards
    action_finder.playable_cards duel.player1
  end

  def ability_cards
    action_finder.ability_cards duel.player1
  end

  def defendable_cards
    action_finder.defendable_cards duel.player1
  end

  def available_attackers
    action_finder.available_attackers duel.player1
  end

  private

    def duel
      # TODO check permissions that we can actually view/interact with this duel
      @duel ||= Duel.find(params[:id])
    end

    def create_card(zone, metaverse_id)
      card = Card.create!( metaverse_id: metaverse_id, turn_played: 0 )
      zone.create! card: card
    end

    def create_order_card(zone, metaverse_id, order)
      card = Card.create!( metaverse_id: metaverse_id, turn_played: 0 )
      zone.create! card: card, order: order
    end

    def find_target
      case params[:target_type]
        when "player"
          Player.find(params[:target])
        when "battlefield"
          Battlefield.find(params[:target])
        when "none"
          nil
        else
          fail "Unknown target type '#{params[:target_type]}'"
      end
    end

    def get_target_type(target)
      return "none" if target == nil
      case target.class.name
        when "Player"
          "player"
        when "Battlefield"
          "battlefield"
        else
          fail "Unknown target type '#{target.class.name}'"
      end
    end

    def action_finder
      @action_finder ||= ActionFinder.new(duel)
    end

end
