require "game_helper"

RSpec.describe "Creature activated abilities", type: :game do
  let(:duel) { create_game }
  let(:card) { duel.player1.hand.first }
  let(:creature) { duel.player1.battlefield.select{ |b| b.card.card_type.actions.include?("add_life") }.first }

  before :each do
    create_hand_cards Library::AddLifeActivated
    duel.playing_phase!
  end

  context "before playing the creature" do
    it "the battlefield is empty" do
      expect(creature).to be_nil
    end
  end

  let(:play) { PlayAction.new(source: card, key: "play") }
  let(:ability) { AbilityAction.new(source: creature, key: "add_life") }

  context "without mana" do
    it "can not be played" do
      expect(play.can_do?(duel)).to be(false)
    end
  end

  context "with mana" do
    before :each do
      tap_all_lands
    end

    it "provides 3 green mana" do
      expect(duel.player1.mana_green).to eq(3)
    end

    it "can be played" do
      expect(play.can_do?(duel)).to be(true)
    end

    context "when played" do
      before :each do
        play.do duel
      end

      it "consumes mana" do
        expect(duel.player1.mana_green).to eq(1)
      end

      it "removes the creature from the hand" do
        expect(duel.player1.hand).to be_empty
      end

      context "after passing to the next phase" do
        before { pass_until_next_phase }

        it "adds a creature to the battlefield" do
          expect(creature).to_not be_nil
        end

        it "is turn 1" do
          expect(duel.turn).to eq(1)
        end

        context "the creature" do
          it "is played on turn 1" do
            expect(creature.card.turn_played).to eq(1)
          end
        end

        context "the activated ability" do
          it "cannot be played" do
            expect(ability.can_do?(duel)).to be(false)
          end
        end
      end

      context "in our next turn" do
        let(:lands) { duel.player1.battlefield_lands }

        before :each do
          pass_until_next_turn
          duel.playing_phase!
        end

        it "all the lands are untapped" do
          lands.each do |land|
            expect(land.card.is_tapped?).to be(false)
          end
        end

        it "the turn number increases" do
          expect(duel.turn).to eq(2)
        end

        context "the creature" do
          it "is a valid card type" do
            expect(creature.card.card_type).to_not be(false)
          end

          it "is not tapped" do
            expect(creature.card.is_tapped?).to be(false)
          end
        end

        context "the activated ability" do
          it "cannot be played" do
            expect(ability.can_do?(duel)).to be(false)
          end

          context "after being tapped manually" do
            before :each do
              creature.card.tap_card!
            end

            it "cannot be played" do
              expect(ability.can_do?(duel)).to be(false)
            end
          end

          context "without mana" do
            it "cannot be activated" do
              expect(ability.can_do?(duel)).to be(false)
            end
          end

          context "with mana" do
            let(:player) { duel.player1 }

            before :each do
              tap_all_lands
            end

            it "can be activated" do
              expect(ability.can_do?(duel)).to be(true)
            end

            it "the player still has 20 life" do
              expect(player.life).to eq(20)
            end

            context "when activated" do
              before :each do
                ability.do duel
              end

              it "the card is tapped" do
                expect(creature.card.is_tapped?).to be(true)
              end
            end
          end
        end
      end
    end
  end

end
