FactoryBot.define do
  factory :trip_game do
    association :trip
    association :stadium
    sequence(:game_pk) { |n| 700_000 + n }
    game_date { Date.current }
    home_team_name { "Home Team" }
    away_team_name { "Away Team" }
    venue_name { "Some Ballpark" }

    trait :attended do
      attended { true }
    end
  end
end
