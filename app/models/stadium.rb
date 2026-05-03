class Stadium < ApplicationRecord
  validates :name, :team_name, :city, :lat, :lng, :mlb_venue_id, presence: true
  validates :mlb_venue_id, uniqueness: true
end
