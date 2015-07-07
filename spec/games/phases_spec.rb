require "game_helper"

RSpec.describe "Phases", type: :game do
  let(:duel) { create_game }

  it "all have unique symbols" do
    player = duel.current_player
    phases = []
    while duel.current_player == player do
      expect(phases).to_not include(duel.phase.to_sym)

      phases << duel.phase.to_sym

      game_engine.pass
      game_engine.pass
    end
  end

  it "have one phase that changes the player" do
    turn = duel.turn
    found = false
    while duel.turn == turn do
      found = true if duel.phase.changes_player?
      game_engine.pass
    end
    expect(found).to be(true)
  end

  it "all have descriptions" do
    turn = duel.turn
    while duel.turn == turn do
      expect(duel.phase.description).to_not be_empty
      game_engine.pass
    end
  end

end
