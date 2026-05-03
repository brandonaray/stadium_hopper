class SearchController < ApplicationController
  def index
    @clusters = []
  end

  def create
    if search_params[:start_date].blank? || search_params[:end_date].blank?
      flash.now[:alert] = "Please enter both a start date and an end date."
      @clusters = []
      render :index, status: :unprocessable_entity
      return
    end

    start_date      = Date.parse(search_params[:start_date])
    end_date        = Date.parse(search_params[:end_date])
    max_trip_days   = search_params[:max_trip_length].present? ? search_params[:max_trip_length].to_i : 7
    max_radius_miles = search_params[:max_radius_miles].present? ? search_params[:max_radius_miles].to_i : 500
    min_stadiums    = search_params[:min_stadiums].present? ? search_params[:min_stadiums].to_i : 2

    @clusters = TripClusterFinder.new(
      start_date:       start_date,
      end_date:         end_date,
      max_trip_days:    max_trip_days,
      max_radius_miles: max_radius_miles,
      min_stadiums:     min_stadiums
    ).find_clusters

    render :index
  end

  private

  def search_params
    params.permit(:start_date, :end_date, :max_trip_length, :max_radius_miles, :min_stadiums)
  end
end
