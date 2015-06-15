class Battlefield < ActiveRecord::Base
  belongs_to :player
  belongs_to :entity

  validates :player, presence: true
  validates :entity, presence: true
  validates :entity, uniqueness: true

  def zone
    BattlefieldZone.new
  end

end
