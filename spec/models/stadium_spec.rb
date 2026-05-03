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

  describe "nil field rejections" do
    it "is invalid without a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to be_present
    end

    it "is invalid without a team_name" do
      subject.team_name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:team_name]).to be_present
    end

    it "is invalid without a city" do
      subject.city = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:city]).to be_present
    end

    it "is invalid without a lat" do
      subject.lat = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:lat]).to be_present
    end

    it "is invalid without a lng" do
      subject.lng = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:lng]).to be_present
    end

    it "is invalid without an mlb_venue_id" do
      subject.mlb_venue_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:mlb_venue_id]).to be_present
    end
  end
end
