class Stadium < ApplicationRecord
  validates :name, :team_name, :city, :lat, :lng, :mlb_venue_id, presence: true
  validates :mlb_venue_id, uniqueness: true

  has_many :trip_games, dependent: :restrict_with_error
  has_many :trips, through: :trip_games
  has_one :visited_stadium, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
end
