$ = require("jquery")

jsonAPI = (url) ->
  new Promise (resolve, reject) ->
    $.getJSON(url).success(resolve).fail(reject)

module.exports = API =
  getDuel: (duel) ->
    jsonAPI("/duel/#{duel}.json")

  getActionLog: (duel) ->
    jsonAPI("/duel/#{duel}/action_log.json")

  getPlayer: (duel, player) ->
    jsonAPI("/duel/#{duel}/player/#{player}.json")

  getPlayerDeck: (duel, player) ->
    jsonAPI("/duel/#{duel}/player/#{player}/deck.json")

  getPlayerBattlefield: (duel, player) ->
    jsonAPI("/duel/#{duel}/player/#{player}/battlefield.json")

  getPlayerHand: (duel, player) ->
    jsonAPI("/duel/#{duel}/player/#{player}/hand.json")

  getPlayerGraveyard: (duel, player) ->
    jsonAPI("/duel/#{duel}/player/#{player}/graveyard.json")

  getActions: (duel, player) ->
    jsonAPI("/duel/#{duel}/player/#{player}/actions.json")
