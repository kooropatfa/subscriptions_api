FactoryBot.define do
  factory :user do
    email    { Faker::Internet.email }
    password { 'letmein' }
  end
end