# spec/factories/tasks.rb

FactoryBot.define do
    factory :task do
      task_title { "Task-#{SecureRandom.hex(4)}" }
      description { "Task description" }
      assign_date { 1.day.ago }
      due_date { 1.day.from_now }
      status { "Todo" }
      priority { "Urgent" }
      user # Creates an associated user
      project # Creates an associated project
    end
  end
  