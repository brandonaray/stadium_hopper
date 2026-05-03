require 'rails_helper'

RSpec.describe VisitedStadium, type: :model do
  subject { build(:visited_stadium) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  describe "uniqueness validations" do
    subject { create(:visited_stadium) }

    it { is_expected.to validate_uniqueness_of(:stadium) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:stadium) }
  end
end
