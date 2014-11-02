FactoryGirl.define do

  factory :user, aliases: [:assignee] do
    email { Faker::Internet.email }
    sequence(:name) { |n| "#{Faker::Internet.user_name}#{n}" }
    password "12345678"
    password_confirmation { password }

    trait :admin do
      admin true
    end

    factory :admin, traits: [:admin]
  end

  factory :project do
    sequence(:code) { |n| "#{Faker::Lorem.characters(6)}#{n}" }
    sequence(:name) { |n| "#{Faker::Lorem.sentence}#{n}" }
  end

  factory :project_opening do
    project
    user
    sequence(:touched) { |n| "#{Faker::Number.number(10)}#{n}" }
  end


  factory :task do
    project
    assignee

    sequence(:name) { |n| "#{Faker::Lorem.characters(8)}#{n}" }
    sequence(:original_estimate) { |n| "#{Faker::Number.number(10)}#{n}" }
    sequence(:remaining_estimate) { |n| "#{Faker::Number.number(10)}#{n}" }
  end

  factory :work_log do
    task

    day '20141010'
    sequence(:worked) { |n| "#{Faker::Number.number(10)}#{n}" }
  end

end