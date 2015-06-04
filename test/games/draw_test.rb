require_relative "game_test"

class DrawTest < GameTest

  test "starting a new turn draws a card" do
    assert_equal 0, @duel.player1.hand.count
    assert_equal 0, @duel.player2.hand.count

    @duel.phase = @duel.total_phases
    @duel.current_player = 2
    @duel.priority_player = 2

    @duel.pass

    assert_equal 0, @duel.player1.hand.count
    assert_equal 0, @duel.player2.hand.count

    @duel.pass

    assert_equal 1, @duel.phase
    assert_equal 1, @duel.player1.hand.count
    assert_equal 0, @duel.player2.hand.count
  end

  test "starting a new turn draws a card for the other player" do
    assert_equal 0, @duel.player1.hand.count
    assert_equal 0, @duel.player2.hand.count

    @duel.phase = @duel.total_phases
    @duel.current_player = 1
    @duel.priority_player = 1

    @duel.pass

    assert_equal 0, @duel.player1.hand.count
    assert_equal 0, @duel.player2.hand.count

    @duel.pass

    assert_equal 1, @duel.phase
    assert_equal 0, @duel.player1.hand.count
    assert_equal 1, @duel.player2.hand.count
  end

end
