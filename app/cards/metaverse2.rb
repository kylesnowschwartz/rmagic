class Metaverse2 < CardType
  def name
    "Forest"
  end

  def is_land?
    true
  end

  def actions
    super + [ "tap", "untap" ]
  end

  def can_do_action?(game_engine, card, index)
    case index
      when "tap"
        return game_engine.duel.priority_player == card.player &&
          game_engine.duel.phase.can_tap? &&
          card.entity.can_tap? &&
          card.zone.can_tap_from?
      when "untap"
        return false # we can never manually untap lands
    end
    super
  end

  def action_cost(game_engine, card, index)
    case index
      when "tap"
        return zero_mana
      when "untap"
        return zero_mana
    end
    super
  end

  def do_action(game_engine, card, index)
    case index
      when "tap"
        return do_tap(game_engine, card)
      when "untap"
        return do_untap(game_engine, card)
    end
    super
  end

  def do_tap(game_engine, card)
    fail "Cannot tap #{card.entity}: already tapped" if card.entity.is_tapped?

    card.player.mana_green += 1
    card.player.save!
    card.entity.tap_card!
  end

  def do_untap(game_engine, card)
    fail "Cannot untap #{card.entity}: already untapped" if !card.entity.is_tapped?

    card.entity.untap_card!
  end

end
