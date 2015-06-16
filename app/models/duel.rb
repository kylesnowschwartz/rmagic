class Duel < ActiveRecord::Base
  belongs_to :player1, class_name: "Player"
  belongs_to :player2, class_name: "Player"

  has_many :declared_attackers, dependent: :destroy
  has_many :declared_defenders, dependent: :destroy
  has_many :actions, dependent: :destroy

  enum phase_number: [ :drawing_phase, :playing_phase, :attacking_phase, :cleanup_phase ]

  after_initialize :init

  def init
    self.turn ||= 1
    self.first_player_number ||= 1
    self.current_player_number ||= 1
    self.priority_player_number ||= 1
    self.phase_number ||= :drawing_phase
  end

  def last_actions
    actions.order(created_at: :desc)
  end

  def players
    [ player1, player2 ]
  end

  def other_player
    if current_player == player1 then player2 else player1 end
  end

  def priority_player
    players[priority_player_number - 1]
  end

  def current_player
    players[current_player_number - 1]
  end

  def phase
    case phase_number
      when "drawing_phase"
        DrawingPhase.new
      when "playing_phase"
        PlayingPhase.new
      when "attacking_phase"
        AttackingPhase.new
      when "cleanup_phase"
        CleanupPhase.new
      else
        fail "Unknown phase '#{phase_number}'"
    end
  end

  def next_phase!
    self.phase_number = phase.next_phase.to_sym
    save!
    return phase.changes_player?
  end

  def phase_text
    phase.description
  end

  def current_turn_text
    "Turn #{turn}, phase #{phase} (#{phase_text}), current player #{current_player_number}, priority player #{priority_player_number}"
  end

end
