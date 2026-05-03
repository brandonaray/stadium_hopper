class MlbApiClient
  class Error < StandardError; end

  BASE_URL = "https://statsapi.mlb.com/api/v1"
  CACHE_TTL = 6.hours

  def fetch_schedule(start_date:, end_date:, force_refresh: false)
    cache_key = "mlb_api/schedule/#{start_date}/#{end_date}"
    fetch_with_cache(cache_key, force_refresh: force_refresh) do
      response = connection.get("schedule") do |req|
        req.params[:sportId]   = 1
        req.params[:startDate] = start_date.to_s
        req.params[:endDate]   = end_date.to_s
        req.params[:hydrate]   = "team,venue,linescore"
      end
      check_response!(response)
      parse_schedule(response.body)
    end
  end

  def fetch_venues(force_refresh: false)
    cache_key = "mlb_api/venues"
    fetch_with_cache(cache_key, force_refresh: force_refresh) do
      response = connection.get("venues") do |req|
        req.params[:sportId] = 1
      end
      check_response!(response)
      parse_venues(response.body)
    end
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |f|
      f.request :retry,
        max: 3,
        interval: 0,
        retry_statuses: [ 500, 502, 503, 504 ],
        exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS
      f.adapter Faraday.default_adapter
    end
  end

  def fetch_with_cache(key, force_refresh: false, &block)
    Rails.cache.delete(key) if force_refresh
    Rails.cache.fetch(key, expires_in: CACHE_TTL, &block)
  end

  def check_response!(response)
    return if response.success?

    raise Error, "MLB Stats API error #{response.status}: #{response.body}"
  end

  def parse_schedule(body)
    data = body.is_a?(String) ? JSON.parse(body) : body
    data.fetch("dates", []).flat_map do |date|
      date.fetch("games", []).map { |game| parse_game(game) }
    end
  end

  def parse_game(game)
    {
      game_pk:        game["gamePk"],
      game_date:      Date.parse(game["gameDate"].to_s.split("T").first),
      status:         game.dig("status", "detailedState"),
      home_team_name: game.dig("teams", "home", "team", "name"),
      home_team_id:   game.dig("teams", "home", "team", "id"),
      away_team_name: game.dig("teams", "away", "team", "name"),
      away_team_id:   game.dig("teams", "away", "team", "id"),
      venue_id:       game.dig("venue", "id"),
      venue_name:     game.dig("venue", "name")
    }
  end

  def parse_venues(body)
    data = body.is_a?(String) ? JSON.parse(body) : body
    data.fetch("venues", []).map { |v| { id: v["id"], name: v["name"] } }
  end
end
