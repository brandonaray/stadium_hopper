# TripsController#create param contract
#
# params[:trip] = {
#   name:        String,                      # required
#   start_date:  String ("YYYY-MM-DD"),       # required
#   end_date:    String ("YYYY-MM-DD"),        # required
#   stadium_ids: [Integer, ...],              # array of Stadium IDs in the cluster
#   games: [
#     {
#       game_pk:        Integer (bigint),
#       game_date:      String ("YYYY-MM-DD"),
#       stadium_id:     Integer,
#       home_team_name: String,
#       away_team_name: String,
#       venue_name:     String
#     },
#     ...
#   ]
# }
#
# Phase 2 views must encode the cluster card form to match this shape.
class TripsController < ApplicationController
  def create
    trip = nil

    ActiveRecord::Base.transaction do
      trip = Trip.create!(
        name:       trip_params[:name],
        start_date: trip_params[:start_date],
        end_date:   trip_params[:end_date]
      )

      (trip_params[:games] || []).each do |game|
        trip.trip_games.create!(
          game_pk:        game[:game_pk],
          game_date:      game[:game_date],
          stadium_id:     game[:stadium_id],
          home_team_name: game[:home_team_name],
          away_team_name: game[:away_team_name],
          venue_name:     game[:venue_name]
        )
      end
    end

    redirect_to root_path, notice: "Trip saved!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: "Could not save trip: #{e.message}"
  end

  private

  def trip_params
    params.require(:trip).permit(
      :name,
      :start_date,
      :end_date,
      stadium_ids: [],
      games: [ :game_pk, :game_date, :stadium_id, :home_team_name, :away_team_name, :venue_name ]
    )
  end
end
