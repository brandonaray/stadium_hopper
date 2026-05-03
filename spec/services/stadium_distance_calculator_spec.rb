require "rails_helper"

RSpec.describe StadiumDistanceCalculator do
  let(:yankee_stadium) { build_stubbed(:stadium, name: "Yankee Stadium", lat: 40.8296, lng: -73.9262) }
  let(:citi_field)     { build_stubbed(:stadium, name: "Citi Field",     lat: 40.7571, lng: -73.8458) }
  let(:dodger_stadium) { build_stubbed(:stadium, name: "Dodger Stadium", lat: 34.0739, lng: -118.2400) }
  let(:angel_stadium)  { build_stubbed(:stadium, name: "Angel Stadium",  lat: 33.8003, lng: -117.8827) }
  let(:fenway_park)    { build_stubbed(:stadium, name: "Fenway Park",    lat: 42.3467, lng: -71.0972) }

  describe ".distance_between" do
    it "returns a Float between 6.0 and 7.5 for Yankee Stadium to Citi Field" do
      result = described_class.distance_between(yankee_stadium, citi_field)
      expect(result).to be_between(6.0, 7.5).inclusive
    end

    it "returns a Float between 25.0 and 32.0 for Dodger Stadium to Angel Stadium" do
      result = described_class.distance_between(dodger_stadium, angel_stadium)
      expect(result).to be_between(25.0, 32.0).inclusive
    end

    it "returns a Float between 175.0 and 185.0 for Fenway Park to Yankee Stadium" do
      result = described_class.distance_between(fenway_park, yankee_stadium)
      expect(result).to be_between(175.0, 185.0).inclusive
    end

    it "returns a Float" do
      expect(described_class.distance_between(yankee_stadium, citi_field)).to be_a(Float)
    end

    it "is rounded to 1 decimal place" do
      result = described_class.distance_between(yankee_stadium, citi_field)
      expect(result).to eq(result.round(1))
    end

    it "is symmetric" do
      expect(described_class.distance_between(yankee_stadium, citi_field))
        .to eq(described_class.distance_between(citi_field, yankee_stadium))
    end

    it "returns 0.0 when both stadiums have identical coordinates" do
      same = build_stubbed(:stadium, lat: 40.8296, lng: -73.9262)
      expect(described_class.distance_between(yankee_stadium, same)).to eq(0.0)
    end
  end

  describe ".distance_matrix" do
    let(:three_stadiums) { [ yankee_stadium, citi_field, dodger_stadium ] }

    it "returns a hash whose top-level keys are exactly the 3 stadium ids" do
      matrix = described_class.distance_matrix(three_stadiums)
      expect(matrix.keys).to contain_exactly(*three_stadiums.map(&:id))
    end

    it "each inner hash has all 3 stadium ids as keys" do
      matrix = described_class.distance_matrix(three_stadiums)
      three_stadiums.each do |s|
        expect(matrix[s.id].keys).to contain_exactly(*three_stadiums.map(&:id))
      end
    end

    it "diagonal entries are 0.0" do
      matrix = described_class.distance_matrix(three_stadiums)
      three_stadiums.each do |s|
        expect(matrix[s.id][s.id]).to eq(0.0)
      end
    end

    it "is symmetric" do
      matrix = described_class.distance_matrix(three_stadiums)
      expect(matrix[yankee_stadium.id][citi_field.id]).to eq(matrix[citi_field.id][yankee_stadium.id])
    end

    it "returns {} for an empty array" do
      expect(described_class.distance_matrix([])).to eq({})
    end
  end

  describe ".within_radius" do
    let(:nearby_stadiums) { [ citi_field, fenway_park, dodger_stadium ] }

    it "returns all stadiums with a very large radius" do
      result = described_class.within_radius(yankee_stadium, nearby_stadiums, max_miles: 10_000)
      expect(result).to contain_exactly(*nearby_stadiums)
    end

    it "returns only stadiums at the same coordinates with radius 0" do
      same_coords = build_stubbed(:stadium, lat: 40.8296, lng: -73.9262)
      result = described_class.within_radius(yankee_stadium, [ same_coords, citi_field ], max_miles: 0)
      expect(result).to contain_exactly(same_coords)
    end

    it "filters correctly with a mid-range radius, returning only Citi Field within 50 miles of Yankee Stadium" do
      result = described_class.within_radius(yankee_stadium, nearby_stadiums, max_miles: 50)
      expect(result).to contain_exactly(citi_field)
    end

    it "returns [] for an empty stadium array" do
      expect(described_class.within_radius(yankee_stadium, [], max_miles: 100)).to eq([])
    end

    it "raises ArgumentError when max_miles is not provided" do
      expect { described_class.within_radius(yankee_stadium, nearby_stadiums) }.to raise_error(ArgumentError)
    end
  end
end
