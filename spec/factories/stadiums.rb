FactoryBot.define do
  factory :stadium do
    sequence(:name) { |n| "Fictional Ballpark #{n}" }
    team_name { "Fictional FC" }
    city { "Springfield" }
    state { "IL" }
    lat { 39.7817 }
    lng { -89.6501 }
    sequence(:mlb_venue_id) { |n| 100_000 + n }
    capacity { 40_000 }
    opened_year { 2000 }
    active { true }
  end
end
