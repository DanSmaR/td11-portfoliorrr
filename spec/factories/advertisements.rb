FactoryBot.define do
  factory :advertisement do
    image { nil }
    link { 'https://www.campuscode.com' }
    display_time { 7 }
    title { Faker::Lorem.paragraph }
    user
  end
end
