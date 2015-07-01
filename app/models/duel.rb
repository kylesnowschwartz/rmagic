class Duel < ActiveRecord::Base
  belongs_to :player1, class_name: "Player"
  belongs_to :player2, class_name: "Player"

  has_many :declared_attackers, dependent: :destroy
  has_many :declared_defenders, dependent: :destroy
  has_many :action_logs, dependent: :destroy
  has_many :stack, dependent: :destroy

  validates :player1, :player2, :turn, :first_player_number,
      :current_player_number, :priority_player_number,
      :phase_number, presence: true

  enum phase_number: [ :drawing_phase, :playing_phase, :attacking_phase, :cleanup_phase ]

  before_validation :init

  def init
    self.turn ||= 1
    self.first_player_number ||= 1
    self.current_player_number ||= 1
    self.priority_player_number ||= 1
    self.phase_number ||= :drawing_phase
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

  def phase
    phase_number.classify.constantize.new
  end

  def next_phase!
    update! phase_number: phase.next_phase.to_sym
    return phase.changes_player?
  end

  def next_stack_order
    return 1 if stack.empty?
    stack.map(&:order).max + 1
  end

end
