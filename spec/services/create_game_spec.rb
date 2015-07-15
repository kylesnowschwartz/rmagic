require 'game_helper'

RSpec.describe CreateGame, type: :service do
  include CreatePremadeDecks

  let(:service) { CreateGame.new(arguments) }
  let(:arguments) { { user1: user1, user2: user2, deck1: deck1, deck2: deck2 } }
  let(:system) { User.create! name: "System" }
  let(:deck1) { create_premade_deck(system) }
  let(:deck2) { create_premade_deck(system) }

  context "with two AI users" do
    let(:user1) { User.create! name: "AI", is_ai: true }
    let(:user2) { User.create! name: "AI", is_ai: true }

    context "#call" do
      let(:duel) { service.call }

      it "returns a duel" do
        expect(duel).to be_a(Duel)
      end

      context "player 1" do
        let(:player) { duel.player1 }

        it "has two cards in the deck" do
          expect(player.deck.count).to eq(2)
        end

        it "does not shuffle cards" do
          expect(player.deck.map{ |c| c.card.card_type.class }).to eq([Library::Forest, Library::Island])
        end

        it "has an empty hand" do
          expect(player.hand).to be_empty
        end

        it "has an empty graveyard" do
          expect(player.graveyard).to be_empty
        end

        it "has an empty battlefield" do
          expect(player.battlefield).to be_empty
        end

        it "is an AI" do
          expect(player).to be_is_ai
        end
      end

      context "player 2" do
        let(:player) { duel.player1 }

        it "has two cards in the deck" do
          expect(player.deck.count).to eq(2)
        end

        it "does not shuffle cards" do
          expect(player.deck.map{ |c| c.card.card_type.class }).to eq([Library::Forest, Library::Island])
        end

        it "has an empty hand" do
          expect(player.hand).to be_empty
        end

        it "has an empty graveyard" do
          expect(player.graveyard).to be_empty
        end

        it "has an empty battlefield" do
          expect(player.battlefield).to be_empty
        end

        it "is an AI" do
          expect(player).to be_is_ai
        end
      end
    end
  end
end
