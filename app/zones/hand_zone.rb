class HandZone < Zone
  def can_instant_from?
    true
  end

  def can_play_from?
    true
  end

  def is_hand?
    true
  end

end
