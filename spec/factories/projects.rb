# spec/factories/projects.rb
FactoryBot.define do
    factory :project do
      name { "Project-#{SecureRandom.hex(4)}" }
      description { "This is a test project with a description." }
      status { "active" }
      start_date { Date.today }
      end_date { Date.today + 1.month }
    end
  end
  