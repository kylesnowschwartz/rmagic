require_relative "setup_game"

RSpec.describe Duel do
  before :each do
    setup
  end

  context "#player1" do

    context "#battlefield" do
      it "contains three cards" do
        expect(@duel.player1.battlefield.length).to eq(3)
      end

      it "contains three lands" do
        expect(@duel.player1.battlefield.lands.length).to eq(3)
      end

      it "contains zero creatures" do
        expect(@duel.player1.battlefield.creatures.length).to eq(0)
      end

      context "adding a creature" do
        before :each do
          create_battlefield_cards 1
        end

        it "contains four cards" do
          expect(@duel.player1.battlefield.length).to eq(4)
        end

        it "contains three lands" do
          expect(@duel.player1.battlefield.lands.length).to eq(3)
        end

        it "contains one creature" do
          expect(@duel.player1.battlefield.creatures.length).to eq(1)
        end
      end
    end

    context "#hand" do
      it "contains zero creatures" do
        expect(@duel.player1.hand.length).to eq(0)
      end

      it "contains zero lands" do
        expect(@duel.player1.hand.lands.length).to eq(0)
      end

      it "contains zero creatures" do
        expect(@duel.player1.hand.creatures.length).to eq(0)
      end

      context "adding a creature" do
        before :each do
          create_hand_cards 1
        end

        it "contains one card" do
          expect(@duel.player1.hand.length).to eq(1)
        end

        it "contains zero lands" do
          expect(@duel.player1.hand.lands.length).to eq(0)
        end

        it "contains one creature" do
          expect(@duel.player1.hand.creatures.length).to eq(1)
        end
      end
    end

  end

end
