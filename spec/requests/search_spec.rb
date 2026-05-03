require "rails_helper"

RSpec.describe "Search", type: :request do
  describe "GET /search" do
    it "returns http 200" do
      get search_path
      expect(response).to have_http_status(:ok)
    end

    it "includes all search form field names in the response body" do
      get search_path
      %w[start_date end_date max_trip_length max_radius_miles min_stadiums].each do |field|
        expect(response.body).to include(field)
      end
    end

    it "includes the empty-state placeholder inside the cluster-results turbo frame" do
      get search_path
      expect(response.body).to include("Pick dates and search to see clusters.")
      expect(response.body).to include('id="cluster-results"')
    end
  end

  describe "POST /search" do
    context "with valid params" do
      let(:start_date) { Date.new(2025, 6, 1) }
      let(:end_date)   { Date.new(2025, 6, 7) }
      let(:stadium)    { create(:stadium, team_name: "River City Rockets", city: "Springfield", mlb_venue_id: 3313) }

      let(:games) do
        [{
          game_pk:        700_001,
          game_date:      start_date,
          venue_id:       stadium.mlb_venue_id,
          home_team_name: "River City Rockets",
          away_team_name: "Visiting Nine",
          venue_name:     stadium.name
        }]
      end

      let(:cluster) do
        TripClusterFinder::Cluster.new(
          stadiums:       [stadium],
          games:          games,
          start_date:     start_date,
          end_date:       end_date,
          total_days:     7,
          distance_miles: 0.0,
          score:          1.0
        )
      end

      let(:finder_double) { instance_double(TripClusterFinder, find_clusters: [cluster]) }

      before do
        allow(TripClusterFinder).to receive(:new).and_return(finder_double)
      end

      it "returns http 200" do
        post search_path, params: { start_date: "2025-06-01", end_date: "2025-06-07" }
        expect(response).to have_http_status(:ok)
      end

      it "includes the cluster stadium team_name in the response body" do
        post search_path, params: { start_date: "2025-06-01", end_date: "2025-06-07" }
        expect(response.body).to include("River City Rockets")
      end

      it "includes the formatted date range in the response body" do
        post search_path, params: { start_date: "2025-06-01", end_date: "2025-06-07" }
        # same month => "June 1–7"
        expect(response.body).to include("June 1")
      end

      it "includes a turbo-frame cluster-results element" do
        post search_path, params: { start_date: "2025-06-01", end_date: "2025-06-07" }
        expect(response.body).to include('id="cluster-results"')
      end
    end

    context "with blank dates" do
      it "returns http 422 and shows the flash alert" do
        expect(TripClusterFinder).not_to receive(:new)
        post search_path, params: { start_date: "", end_date: "" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Please enter both a start date and an end date.")
      end
    end

    context "kwarg bridge: max_trip_length param maps to max_trip_days" do
      let(:finder_double) { instance_double(TripClusterFinder, find_clusters: []) }

      it "passes max_trip_days: 5 when max_trip_length param is 5" do
        expect(TripClusterFinder).to receive(:new).with(
          start_date:       Date.new(2025, 6, 1),
          end_date:         Date.new(2025, 6, 7),
          max_trip_days:    5,
          max_radius_miles: 500,
          min_stadiums:     2
        ).and_return(finder_double)

        post search_path, params: {
          start_date:      "2025-06-01",
          end_date:        "2025-06-07",
          max_trip_length: "5"
        }
      end
    end
  end
end
