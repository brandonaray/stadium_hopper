class StadiumDistanceCalculator
  EARTH_RADIUS_MILES = 3_958.8

  class << self
    def distance_between(stadium_a, stadium_b)
      lat1 = stadium_a.lat.to_f
      lng1 = stadium_a.lng.to_f
      lat2 = stadium_b.lat.to_f
      lng2 = stadium_b.lng.to_f

      dlat = to_rad(lat2 - lat1)
      dlng = to_rad(lng2 - lng1)
      a = Math.sin(dlat / 2)**2 + Math.cos(to_rad(lat1)) * Math.cos(to_rad(lat2)) * Math.sin(dlng / 2)**2
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      (EARTH_RADIUS_MILES * c).round(1)
    end

    def distance_matrix(stadiums)
      stadiums.each_with_object({}) do |a, matrix|
        matrix[a.id] = stadiums.each_with_object({}) do |b, row|
          row[b.id] = a.id == b.id ? 0.0 : distance_between(a, b)
        end
      end
    end

    def within_radius(origin_stadium, stadiums, max_miles:)
      stadiums.select { |s| distance_between(origin_stadium, s) <= max_miles }
    end

    private

    def to_rad(deg)
      deg.to_f * Math::PI / 180
    end
  end
end
