FactoryBot.define do
  factory :post do
    user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph sentence_count: rand(35..50) }
    edited_at { Time.zone.now }

    trait :published do
      published_at { Time.zone.now }
      status { :published }
    end
  end
end
