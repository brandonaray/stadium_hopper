FactoryBot.define do
  factory :visited_stadium do
    association :stadium
    visited_on { Date.current }
  end
end
