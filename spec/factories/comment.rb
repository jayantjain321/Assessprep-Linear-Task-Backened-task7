# spec/factories/comments.rb
FactoryBot.define do
    factory :comment do
      text { "This is a comment" }
      task
      user
    end
end
  