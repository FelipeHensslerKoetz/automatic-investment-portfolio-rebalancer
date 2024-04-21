# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    provider { 'email' }
    uid { email }
    email { Faker::Internet.email }
    password { 'password' }
    encrypted_password { 'p@ssw0rd' }
  end
end
