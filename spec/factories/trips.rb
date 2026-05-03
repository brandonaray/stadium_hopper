FactoryBot.define do
  factory :trip do
    sequence(:name) { |n| "Trip #{n}" }
    start_date { Date.current }
    end_date { Date.current + 3 }
  end
end
