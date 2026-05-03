require "rails_helper"

RSpec.describe "Trips", type: :request do
  describe "POST /trips" do
    let(:stadium) { create(:stadium) }

    context "with valid params" do
      let(:valid_params) do
        {
          trip: {
            name:        "My Road Trip",
            start_date:  "2025-06-01",
            end_date:    "2025-06-07",
            stadium_ids: [ stadium.id ],
            games:       [
              {
                game_pk:        700_001,
                game_date:      "2025-06-01",
                stadium_id:     stadium.id,
                home_team_name: "Home Team",
                away_team_name: "Away Team",
                venue_name:     "Fictional Ballpark"
              },
              {
                game_pk:        700_002,
                game_date:      "2025-06-03",
                stadium_id:     stadium.id,
                home_team_name: "Home Team",
                away_team_name: "Away Team",
                venue_name:     "Fictional Ballpark"
              }
            ]
          }
        }
      end

      it "increases Trip count by 1" do
        expect { post trips_path, params: valid_params }.to change(Trip, :count).by(1)
      end

      it "increases TripGame count by 2 (one per game)" do
        expect { post trips_path, params: valid_params }.to change(TripGame, :count).by(2)
      end

      it "redirects (302) with a flash notice" do
        post trips_path, params: valid_params
        expect(response).to have_http_status(:found)
        expect(flash[:notice]).to eq("Trip saved!")
      end
    end

    context "with invalid params (missing name)" do
      let(:invalid_params) do
        {
          trip: {
            name:       "",
            start_date: "2025-06-01",
            end_date:   "2025-06-07"
          }
        }
      end

      it "does not create a Trip" do
        expect { post trips_path, params: invalid_params }.not_to change(Trip, :count)
      end

      it "redirects (302) with a flash alert" do
        post trips_path, params: invalid_params
        expect(response).to have_http_status(:found)
        expect(flash[:alert]).to match(/Could not save trip/)
      end
    end
  end
end
