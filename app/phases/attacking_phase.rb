class AttackingPhase < Phase
  def can_tap?
    true
  end

  def can_instant?
    true
  end

  def can_ability?
    true
  end

  def can_declare_attackers?
    true
  end

  def can_declare_defenders?
    true
  end

  def next_phase
    CleanupPhase.new
  end

  def to_sym
    :attacking_phase
  end

  def description
    "attack phase: declare attackers and defenders"
  end

  def enter_phase_service
    EnterAttackingPhase
  end

end
