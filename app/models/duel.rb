class Duel < ActiveRecord::Base
  include SafeJson
  include Subscribable

  belongs_to :player1, class_name: "Player"
  belongs_to :player2, class_name: "Player"

  has_many :declared_attackers, dependent: :destroy
  has_many :declared_defenders, dependent: :destroy
  has_many :action_logs, dependent: :destroy
  has_many :stack, dependent: :destroy

  validates :player1, :player2, :turn, :first_player_number,
      :current_player_number, :priority_player_number,
      :phase_number, presence: true

  enum phase_number: [ :mulligan_phase, :completed_mulligans_phase, :drawing_phase, :playing_phase, :attacking_phase, :cleanup_phase ]

  before_validation :init

  def init
    self.turn ||= 1
    self.first_player_number ||= 1
    self.current_player_number ||= 1
    self.priority_player_number ||= 1
    self.phase_number ||= :mulligan_phase
  end

  def players
    [ player1, player2 ]
  end

  def other_player
    current_player == player1 ? player2 : player1
  end

  def priority_player
    players[priority_player_number - 1]
  end

  def current_player
    players[current_player_number - 1]
  end

  def first_player
    players[first_player_number - 1]
  end

  def reset_priority!
    update! priority_player_number: current_player_number
  end

  def phase
    phase_number.classify.constantize.new
  end

  def next_phase!
    update! phase_number: phase.next_phase.to_sym
    return phase.changes_player?
  end

  def enter_phase!
    phase.enter_phase_service.new(duel: self).call
  end

  def next_stack_order
    return 1 if stack.empty?
    stack.map(&:order).max + 1
  end

  def title
    "#{player1.name} (#{player1.life}) v #{player2.name} (#{player2.life})"
  end

  def zones
    [ stack ]
  end

  def safe_json_attributes
    [ :id, :current_player_number, :priority_player_number,
      :first_player_number, :turn, :phase_number, :player1_id, :player2_id ]
  end

  def extra_json_attributes
    {
      phase: phase_number,
      first_player: first_player.safe_json,
      current_player: current_player.safe_json,
      priority_player: priority_player.safe_json
    }
  end

  def action_log_json
    {
      logs: action_logs.order(created_at: :desc).limit(10).map(&:safe_json)
    }
  end

  after_update :update_action_log_channels

  def update_action_log_channels(source = nil)
    # TODO add this pattern to all other channels to reduce load on tests
    if WebsocketRails["action_log/#{id}"].subscribers.any?
      json = self.action_log_json
      if source
        json[:source] = source
      end

      # trigger an update on all channels
      WebsocketRails["action_log/#{id}"].trigger "update", json
    end
  end

end
