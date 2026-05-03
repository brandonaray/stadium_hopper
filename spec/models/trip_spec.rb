require 'rails_helper'

RSpec.describe Trip, type: :model do
  subject { build(:trip) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  describe "presence validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:trip_games).dependent(:destroy) }
    it { is_expected.to have_many(:stadiums).through(:trip_games) }
  end

  describe "date ordering" do
    it "is valid when end_date equals start_date" do
      subject.start_date = Date.new(2026, 5, 1)
      subject.end_date = Date.new(2026, 5, 1)
      expect(subject).to be_valid
    end

    it "is valid when end_date is after start_date" do
      subject.start_date = Date.new(2026, 5, 1)
      subject.end_date = Date.new(2026, 5, 5)
      expect(subject).to be_valid
    end

    it "is invalid when end_date is before start_date" do
      subject.start_date = Date.new(2026, 5, 5)
      subject.end_date = Date.new(2026, 5, 1)
      expect(subject).not_to be_valid
      expect(subject.errors[:end_date]).to be_present
    end
  end
end
