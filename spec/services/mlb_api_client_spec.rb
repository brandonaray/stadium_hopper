require "rails_helper"

RSpec.describe MlbApiClient do
  subject(:client) { described_class.new }

  let(:base_url) { "https://statsapi.mlb.com/api/v1" }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  describe "#fetch_schedule" do
    let(:start_date) { Date.new(2024, 4, 1) }
    let(:end_date)   { Date.new(2024, 4, 7) }

    let(:game_payload) do
      {
        "gamePk"   => 745455,
        "gameDate" => "2024-04-01T17:05:00Z",
        "status"   => { "detailedState" => "Final" },
        "teams"    => {
          "home" => { "team" => { "id" => 147, "name" => "New York Yankees" } },
          "away" => { "team" => { "id" => 110, "name" => "Baltimore Orioles" } }
        },
        "venue" => { "id" => 3313, "name" => "Yankee Stadium" }
      }
    end

    let(:schedule_body) do
      { "dates" => [ { "date" => "2024-04-01", "games" => [ game_payload ] } ] }.to_json
    end

    def stub_schedule(status: 200, body: schedule_body)
      stub_request(:get, /statsapi\.mlb\.com.*\/schedule/)
        .to_return(status: status, body: body, headers: json_headers)
    end

    context "with a successful response" do
      before { stub_schedule }

      it "returns an array" do
        expect(client.fetch_schedule(start_date: start_date, end_date: end_date)).to be_an(Array)
      end

      it "returns one game for the fixture payload" do
        result = client.fetch_schedule(start_date: start_date, end_date: end_date)
        expect(result.length).to eq(1)
      end

      describe "game hash fields" do
        subject(:game) { client.fetch_schedule(start_date: start_date, end_date: end_date).first }

        it { expect(game[:game_pk]).to eq(745455) }
        it { expect(game[:game_date]).to eq(Date.new(2024, 4, 1)) }
        it { expect(game[:game_date]).to be_a(Date) }
        it { expect(game[:status]).to eq("Final") }
        it { expect(game[:home_team_name]).to eq("New York Yankees") }
        it { expect(game[:home_team_id]).to eq(147) }
        it { expect(game[:away_team_name]).to eq("Baltimore Orioles") }
        it { expect(game[:away_team_id]).to eq(110) }
        it { expect(game[:venue_id]).to eq(3313) }
        it { expect(game[:venue_name]).to eq("Yankee Stadium") }
      end
    end

    context "when the dates array is empty" do
      before { stub_schedule(body: { "dates" => [] }.to_json) }

      it "returns an empty array" do
        result = client.fetch_schedule(start_date: start_date, end_date: end_date)
        expect(result).to eq([])
      end
    end

    context "when the API returns a 5xx error" do
      before { stub_schedule(status: 503, body: "Service Unavailable") }

      it "raises MlbApiClient::Error" do
        expect {
          client.fetch_schedule(start_date: start_date, end_date: end_date)
        }.to raise_error(MlbApiClient::Error, /503/)
      end
    end

    context "with force_refresh: true" do
      before { stub_schedule(body: { "dates" => [] }.to_json) }

      it "deletes the cache key before fetching" do
        expect(Rails.cache).to receive(:delete)
          .with("mlb_api/schedule/2024-04-01/2024-04-07")
        client.fetch_schedule(start_date: start_date, end_date: end_date, force_refresh: true)
      end
    end

    context "without force_refresh" do
      before { stub_schedule(body: { "dates" => [] }.to_json) }

      it "does not delete the cache key" do
        expect(Rails.cache).not_to receive(:delete)
        client.fetch_schedule(start_date: start_date, end_date: end_date)
      end
    end
  end

  describe "#fetch_venues" do
    let(:venues_body) do
      {
        "venues" => [
          { "id" => 3313, "name" => "Yankee Stadium" },
          { "id" => 31,   "name" => "Chase Field" }
        ]
      }.to_json
    end

    def stub_venues(status: 200, body: venues_body)
      stub_request(:get, /statsapi\.mlb\.com.*\/venues/)
        .to_return(status: status, body: body, headers: json_headers)
    end

    context "with a successful response" do
      before { stub_venues }

      it "returns an array" do
        expect(client.fetch_venues).to be_an(Array)
      end

      it "returns two venues for the fixture payload" do
        expect(client.fetch_venues.length).to eq(2)
      end

      describe "venue hash fields" do
        subject(:venue) { client.fetch_venues.first }

        it { expect(venue[:id]).to eq(3313) }
        it { expect(venue[:name]).to eq("Yankee Stadium") }
      end
    end

    context "when venues array is empty" do
      before { stub_venues(body: { "venues" => [] }.to_json) }

      it "returns an empty array" do
        expect(client.fetch_venues).to eq([])
      end
    end

    context "when the API returns a 5xx error" do
      before { stub_venues(status: 500, body: "Internal Server Error") }

      it "raises MlbApiClient::Error" do
        expect { client.fetch_venues }.to raise_error(MlbApiClient::Error, /500/)
      end
    end

    context "with force_refresh: true" do
      before { stub_venues(body: { "venues" => [] }.to_json) }

      it "deletes the cache key before fetching" do
        expect(Rails.cache).to receive(:delete).with("mlb_api/venues")
        client.fetch_venues(force_refresh: true)
      end
    end

    context "without force_refresh" do
      before { stub_venues(body: { "venues" => [] }.to_json) }

      it "does not delete the cache key" do
        expect(Rails.cache).not_to receive(:delete)
        client.fetch_venues
      end
    end
  end
end
