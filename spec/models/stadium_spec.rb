require 'rails_helper'

RSpec.describe Stadium, type: :model do
  subject { build(:stadium) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  describe "presence validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:team_name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:lat) }
    it { is_expected.to validate_presence_of(:lng) }
    it { is_expected.to validate_presence_of(:mlb_venue_id) }
  end

  describe "uniqueness validations" do
    it { is_expected.to validate_uniqueness_of(:mlb_venue_id) }
  end

  describe "associations" do
    it { is_expected.to have_many(:trip_games).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:trips).through(:trip_games) }
    it { is_expected.to have_one(:visited_stadium).dependent(:restrict_with_error) }
  end

  describe ".active" do
    it "returns only stadiums where active is true" do
      active_stadium = create(:stadium)
      create(:stadium, active: false)

      expect(Stadium.active).to contain_exactly(active_stadium)
    end
  end

  describe "destruction restrictions" do
    it "cannot be destroyed while trip_games exist" do
      stadium = create(:stadium)
      create(:trip_game, stadium: stadium)

      expect(stadium.destroy).to be_falsey
      expect(stadium.errors[:base]).to be_present
      expect(Stadium.exists?(stadium.id)).to be true
    end
  end
end
