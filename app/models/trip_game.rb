class TripGame < ApplicationRecord
  validates :game_pk, :game_date, presence: true
  validates :game_pk, uniqueness: { scope: :trip_id }

  belongs_to :trip
  belongs_to :stadium

  after_save :sync_visited_stadium

  private

  def sync_visited_stadium
    return unless attended?
    return unless saved_change_to_attended?

    stadium.visited_stadium || stadium.create_visited_stadium!(visited_on: game_date)
  end
end
