class VisitedStadium < ApplicationRecord
  validates :stadium, uniqueness: true

  belongs_to :stadium
end
