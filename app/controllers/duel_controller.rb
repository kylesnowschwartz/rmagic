class DuelController < ApplicationController
  def new
    # create a temporary duel to display
    @player1 = Player.create!(
     name: "Jevon",
     life: 20,
     is_ai: false
    )
    @player2 = Player.create(
      name: "AI",
      life: 15,
      is_ai: true
    )

    @duel = Duel.create!( player1: @player1, player2: @player2 )

    @entity1 = Entity.create!( metaverse_id: 1 )

    10.times { Deck.create!( entity: @entity1, player: @player1 ) }
    10.times { Deck.create( entity: @entity1, player: @player2 ) }

    Hand.create!( entity: @entity1, player: @player1 )
    Hand.create!( entity: @entity1, player: @player2 )

    Battlefield.create!( entity: @entity1, player: @player1 )
    Battlefield.create!( entity: @entity1, player: @player2 )

    @action1 = Action.create!( entity: @entity1, entity_action: 0, player: @player2, duel: @duel )
    @action_target1 = ActionTarget.create!( entity: @entity1, action: @action1, damage: 1 )

    redirect_to duel_path @duel
  end

  def duel
    Duel.find(params[:id])
  end

  def show
    @duel = duel
  end

  def pass
    duel.pass
    duel.save!
    redirect_to duel_path duel
  end

  def play
    @hand = Hand.find(params[:hand])
    game_engine.play @hand
    redirect_to duel_path duel
  end

  helper_method :available_actions

  def available_actions
    game_engine.available_actions
  end

  def game_engine
    GameEngine.new(duel)
  end

end
