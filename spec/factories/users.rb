# spec/factories/users.rb

FactoryBot.define do
    factory :user do
      name { "jay" }
      sequence(:email) { |n| "user#{n}@example.com" }
      password { "password" }
      position { "Developer" }
    end
  end
  