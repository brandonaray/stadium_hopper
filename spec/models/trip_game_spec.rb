require 'rails_helper'

RSpec.describe TripGame, type: :model do
  subject { build(:trip_game) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  describe "presence validations" do
    it { is_expected.to validate_presence_of(:game_pk) }
    it { is_expected.to validate_presence_of(:game_date) }
  end

  describe "uniqueness validations" do
    subject { create(:trip_game) }

    it { is_expected.to validate_uniqueness_of(:game_pk).scoped_to(:trip_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:trip) }
    it { is_expected.to belong_to(:stadium) }
  end

  describe "visited stadium sync" do
    let(:stadium) { create(:stadium) }

    it "creates a VisitedStadium when attended is true on create" do
      trip_game = build(:trip_game, :attended, stadium: stadium, game_date: Date.new(2026, 5, 1))

      expect { trip_game.save! }.to change { stadium.reload.visited_stadium }.from(nil)
      expect(stadium.visited_stadium.visited_on).to eq(Date.new(2026, 5, 1))
    end

    it "creates a VisitedStadium when attended flips from false to true" do
      trip_game = create(:trip_game, stadium: stadium, game_date: Date.new(2026, 6, 1))

      expect { trip_game.update!(attended: true) }.to change { stadium.reload.visited_stadium }.from(nil)
      expect(stadium.visited_stadium.visited_on).to eq(Date.new(2026, 6, 1))
    end

    it "does not create a VisitedStadium when attended remains false" do
      trip_game = create(:trip_game, stadium: stadium)

      expect { trip_game.update!(home_team_name: "Updated") }.not_to change { stadium.reload.visited_stadium }
    end

    it "does not destroy an existing VisitedStadium when attended flips back to false" do
      trip_game = create(:trip_game, :attended, stadium: stadium)
      visited = stadium.reload.visited_stadium

      trip_game.update!(attended: false)

      expect(stadium.reload.visited_stadium).to eq(visited)
    end

    it "does not duplicate a VisitedStadium when a second attended game is added" do
      create(:trip_game, :attended, stadium: stadium, game_date: Date.new(2026, 5, 1))
      original = stadium.reload.visited_stadium

      create(:trip_game, :attended, stadium: stadium, game_date: Date.new(2026, 7, 1))

      expect(stadium.reload.visited_stadium).to eq(original)
    end

    it "does not duplicate a VisitedStadium on an unrelated update to an attended game" do
      trip_game = create(:trip_game, :attended, stadium: stadium)
      original = stadium.reload.visited_stadium

      trip_game.update!(home_team_name: "Changed")

      expect(stadium.reload.visited_stadium).to eq(original)
    end
  end
end
