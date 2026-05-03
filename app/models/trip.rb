class Trip < ApplicationRecord
  validates :name, presence: true
  validate :end_date_after_start_date

  has_many :trip_games, dependent: :destroy
  has_many :stadiums, through: :trip_games

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    return if end_date >= start_date

    errors.add(:end_date, "must be on or after the start date")
  end
end
