FactoryBot.define do
  factory :product do
    name { "#{Faker::Games::Pokemon.name} pack"  }
    billing_interval { 1 }
    price { 1000 }
  end
end