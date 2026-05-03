require "rails_helper"

RSpec.describe TripClusterFinder do
  let(:start_date) { Date.new(2025, 4, 1) }
  let(:end_date)   { Date.new(2025, 4, 7) }

  let(:api_client) { instance_double(MlbApiClient) }

  # Real DB records with actual MLB coordinates so StadiumDistanceCalculator runs real math.
  # Yankee–Citi ≈ 6.6 mi, Yankee–Fenway ≈ 215 mi, Yankee–Dodger ≈ 2450 mi.
  let!(:yankee) do
    create(:stadium, mlb_venue_id: 3313, name: "Yankee Stadium",
           team_name: "New York Yankees", city: "New York", lat: 40.8296, lng: -73.9262)
  end
  let!(:citi) do
    create(:stadium, mlb_venue_id: 3289, name: "Citi Field",
           team_name: "New York Mets", city: "New York", lat: 40.7571, lng: -73.8458)
  end
  let!(:fenway) do
    create(:stadium, mlb_venue_id: 3, name: "Fenway Park",
           team_name: "Boston Red Sox", city: "Boston", lat: 42.3467, lng: -71.0972)
  end
  let!(:dodger) do
    create(:stadium, mlb_venue_id: 22, name: "Dodger Stadium",
           team_name: "Los Angeles Dodgers", city: "Los Angeles", lat: 34.0739, lng: -118.2400)
  end

  before { allow(MlbApiClient).to receive(:new).and_return(api_client) }

  def game(venue_id:, date:, pk: nil)
    {
      game_pk:        pk || (venue_id * 1000 + date.yday),
      game_date:      date,
      venue_id:       venue_id,
      venue_name:     "Stadium",
      status:         "Scheduled",
      home_team_name: "Home Team",
      home_team_id:   1,
      away_team_name: "Away Team",
      away_team_id:   2
    }
  end

  def finder(**opts)
    defaults = { start_date: start_date, end_date: end_date }
    TripClusterFinder.new(**defaults.merge(opts))
  end

  describe "#find_clusters" do
    context "when schedule is empty" do
      before { allow(api_client).to receive(:fetch_schedule).and_return([]) }

      it "returns an empty array" do
        expect(finder.find_clusters).to eq([])
      end
    end

    context "with a single-stadium schedule" do
      before do
        allow(api_client).to receive(:fetch_schedule).and_return([
          game(venue_id: 3313, date: start_date)
        ])
      end

      it "returns no clusters" do
        expect(finder.find_clusters).to eq([])
      end
    end

    context "with two nearby stadiums (Yankee and Citi, ~7 miles apart)" do
      let(:nearby_games) do
        [
          game(venue_id: 3313, date: start_date,     pk: 1),
          game(venue_id: 3289, date: start_date + 2, pk: 2)
        ]
      end

      before { allow(api_client).to receive(:fetch_schedule).and_return(nearby_games) }

      subject(:cluster) { finder.find_clusters.first }

      it "returns exactly one cluster" do
        expect(finder.find_clusters.size).to eq(1)
      end

      it "includes both stadiums" do
        expect(cluster.stadiums).to contain_exactly(yankee, citi)
      end

      it "includes both games" do
        expect(cluster.games).to match_array(nearby_games)
      end

      it "has the correct start_date" do
        expect(cluster.start_date).to eq(start_date)
      end

      it "has end_date on or after the second game date" do
        expect(cluster.end_date).to be >= start_date + 2
      end

      it "has total_days >= 3" do
        expect(cluster.total_days).to be >= 3
      end

      it "has distance_miles below 50" do
        expect(cluster.distance_miles).to be < 50.0
      end

      it "has a positive Float score" do
        expect(cluster.score).to be_a(Float)
        expect(cluster.score).to be > 0
      end
    end

    context "with two far-apart stadiums (Yankee and Dodger, ~2450 miles)" do
      before do
        allow(api_client).to receive(:fetch_schedule).and_return([
          game(venue_id: 3313, date: start_date),
          game(venue_id: 22,   date: start_date + 1)
        ])
      end

      it "returns no clusters" do
        expect(finder(max_radius_miles: 500).find_clusters).to eq([])
      end
    end

    context "when venue_id has no matching Stadium record" do
      before do
        allow(api_client).to receive(:fetch_schedule).and_return([
          game(venue_id: 99999, date: start_date),
          game(venue_id: 3313,  date: start_date + 1)
        ])
      end

      it "ignores the unknown venue and returns no cluster" do
        expect(finder.find_clusters).to eq([])
      end
    end

    context "with overlapping windows producing the same stadium set" do
      # Yankee and Citi both play Apr 1 and Apr 4.
      # With max_trip_days: 4, windows Apr1-4, Apr2-5, Apr3-6, Apr4-7 all find both stadiums.
      # All overlap → deduplicates to a single cluster.
      let(:overlap_games) do
        [
          game(venue_id: 3313, date: start_date,     pk: 1),
          game(venue_id: 3289, date: start_date,     pk: 2),
          game(venue_id: 3313, date: start_date + 3, pk: 3),
          game(venue_id: 3289, date: start_date + 3, pk: 4)
        ]
      end

      before { allow(api_client).to receive(:fetch_schedule).and_return(overlap_games) }

      let(:results) { finder(end_date: Date.new(2025, 4, 10), max_trip_days: 4).find_clusters }

      it "deduplicates to a single cluster" do
        expect(results.size).to eq(1)
      end

      it "merged cluster starts on the earliest window start" do
        expect(results.first.start_date).to eq(start_date)
      end

      it "merged cluster ends on or after the last game date" do
        expect(results.first.end_date).to be >= start_date + 3
      end

      it "merged cluster contains all 4 unique games" do
        expect(results.first.games.size).to eq(4)
      end
    end

    context "scoring and ordering with 3 stadiums" do
      # Apr 1–3: Yankee, Citi, Fenway all play → 3-stadium cluster windows.
      # Apr 8–9: only Yankee + Citi play → 2-stadium cluster windows.
      # After dedup: one 3-stadium cluster (higher score) and one 2-stadium cluster.
      let(:end_date) { Date.new(2025, 4, 14) }

      let(:scoring_games) do
        [
          game(venue_id: 3313, date: start_date,     pk: 10),
          game(venue_id: 3289, date: start_date + 1, pk: 11),
          game(venue_id: 3,    date: start_date + 2, pk: 12),
          game(venue_id: 3313, date: start_date + 7, pk: 13),
          game(venue_id: 3289, date: start_date + 8, pk: 14)
        ]
      end

      before { allow(api_client).to receive(:fetch_schedule).and_return(scoring_games) }

      let(:results) { finder.find_clusters }

      it "returns at least 2 clusters" do
        expect(results.size).to be >= 2
      end

      it "places the 3-stadium cluster first" do
        expect(results.first.stadiums.size).to eq(3)
      end

      it "3-stadium cluster has a higher score than 2-stadium cluster" do
        three_s = results.find { |c| c.stadiums.size == 3 }
        two_s   = results.find { |c| c.stadiums.size == 2 }
        expect(three_s.score).to be > two_s.score
      end
    end

    context "when min_stadiums threshold is not met" do
      before do
        allow(api_client).to receive(:fetch_schedule).and_return([
          game(venue_id: 3313, date: start_date),
          game(venue_id: 3289, date: start_date + 1)
        ])
      end

      it "returns no clusters when min_stadiums is 3 but only 2 are present" do
        expect(finder(min_stadiums: 3).find_clusters).to eq([])
      end
    end

    context "when max_trip_days is too short to span the games" do
      # Yankee: Apr 1, Citi: Apr 5 — need a 5-day window; max_trip_days: 3 cannot cover both.
      before do
        allow(api_client).to receive(:fetch_schedule).and_return([
          game(venue_id: 3313, date: start_date),
          game(venue_id: 3289, date: start_date + 4)
        ])
      end

      it "returns no clusters" do
        expect(finder(max_trip_days: 3).find_clusters).to eq([])
      end
    end
  end
end
