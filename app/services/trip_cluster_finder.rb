class TripClusterFinder
  Cluster = Struct.new(:stadiums, :games, :start_date, :end_date, :total_days, :distance_miles, :score, keyword_init: true)

  def initialize(start_date:, end_date:, max_trip_days: 7, max_radius_miles: 500, min_stadiums: 2)
    @start_date       = start_date
    @end_date         = end_date
    @max_trip_days    = max_trip_days
    @max_radius_miles = max_radius_miles
    @min_stadiums     = min_stadiums
  end

  def find_clusters
    games     = fetch_games
    venue_map = build_venue_map(games)

    raw = []
    (@start_date..@end_date).each do |window_start|
      window_end   = [ window_start + @max_trip_days - 1, @end_date ].min
      window_games = games_in_window(games, window_start, window_end)
      next if window_games.empty?

      venue_ids = window_games.map { |g| g[:venue_id] }.uniq.compact
      stadiums  = venue_ids.filter_map { |vid| venue_map[vid] }
      next if stadiums.size < @min_stadiums
      next unless all_within_radius?(stadiums)

      raw << {
        stadium_ids:    stadiums.map(&:id).sort,
        stadiums:       stadiums,
        games:          window_games,
        start_date:     window_start,
        end_date:       window_end,
        distance_miles: max_pairwise_distance(stadiums)
      }
    end

    deduplicate(raw).map { |c| build_cluster(c) }.sort_by { |c| -c.score }
  end

  private

  def fetch_games
    MlbApiClient.new.fetch_schedule(start_date: @start_date, end_date: @end_date)
  end

  def build_venue_map(games)
    ids = games.map { |g| g[:venue_id] }.uniq.compact
    Stadium.where(mlb_venue_id: ids).index_by(&:mlb_venue_id)
  end

  def games_in_window(games, window_start, window_end)
    games.select { |g| g[:game_date] >= window_start && g[:game_date] <= window_end }
  end

  def all_within_radius?(stadiums)
    stadiums.combination(2).all? do |a, b|
      StadiumDistanceCalculator.distance_between(a, b) <= @max_radius_miles
    end
  end

  def max_pairwise_distance(stadiums)
    return 0.0 if stadiums.size < 2
    stadiums.combination(2).map { |a, b| StadiumDistanceCalculator.distance_between(a, b) }.max.to_f
  end

  def deduplicate(raw)
    raw.group_by { |c| c[:stadium_ids] }.flat_map do |_, entries|
      merge_overlapping(entries.sort_by { |e| e[:start_date] })
    end
  end

  def merge_overlapping(sorted_entries)
    merged = []
    sorted_entries.each do |entry|
      if merged.empty? || entry[:start_date] > merged.last[:end_date]
        merged << entry.dup
      else
        last = merged.last
        last[:end_date] = [ last[:end_date], entry[:end_date] ].max
        last[:games]    = (last[:games] + entry[:games]).uniq { |g| g[:game_pk] }
      end
    end
    merged
  end

  def build_cluster(entry)
    total_days = (entry[:end_date] - entry[:start_date]).to_i + 1
    dist       = entry[:distance_miles]
    score      = (entry[:stadiums].count.to_f**2 / (total_days.to_f * (1.0 + dist / 500.0))).round(4)
    Cluster.new(
      stadiums:       entry[:stadiums],
      games:          entry[:games],
      start_date:     entry[:start_date],
      end_date:       entry[:end_date],
      total_days:     total_days,
      distance_miles: dist,
      score:          score
    )
  end
end
