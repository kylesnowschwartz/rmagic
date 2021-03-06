class CreateDuelRequest
  attr_reader :user, :premade_deck

  def initialize(user:, premade_deck:)
    @user = user
    @premade_deck = premade_deck
  end

  def call
    # is there an existing duel request we can match this player with?
    request = DuelRequest.first
    if request
      # remove the request
      request.destroy

      # random first player
      flip = [true, false].sample

      if flip
        return CreateGame.new(user1: request.user, user2: user, deck1: request.premade_deck, deck2: premade_deck).call
      else
        return CreateGame.new(user1: user, user2: request.user, deck1: premade_deck, deck2: request.premade_deck).call
      end
    else
      # create a new duel request
      user.duel_requests.create! premade_deck: premade_deck

      return true
    end
  end

end
