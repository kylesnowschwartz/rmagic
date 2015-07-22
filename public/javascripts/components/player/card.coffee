$ = require('jquery')
React = require("react")

module.exports = Card = React.createClass
  render: ->
    card_link = "/cards/#{this.props.card.card_type.metaverse_id}"
    power = ""
    if this.props.card.card_type.is_creature
      power = `<span className="power">({this.props.card.power} / {this.props.card.toughness})</span>`
    tapped = ""
    if this.props.card.is_tapped
      tapped = `<i>(tapped)</i>`

    classes = "card metaverse-#{this.props.card.card_type.metaverse_id}"

    `<li className={classes} key={this.props.id}>
      <div className="card-hover">
        <div className={classes}>
          <div className="card-text">
            <a href={card_link}>{this.props.card.card_type.name} {this.props.card.card_type.mana_cost}</a>
            {power}
            <small>{this.props.card.id}</small>
            {tapped}
          </div>
        </div>
      </div>

      <div className="card-text">
        <a href={card_link}>{this.props.card.card_type.name} {this.props.card.card_type.mana_cost}</a>
        {power}
        <small>{this.props.card.id}</small>
        {tapped}
      </div>
    </li>`
