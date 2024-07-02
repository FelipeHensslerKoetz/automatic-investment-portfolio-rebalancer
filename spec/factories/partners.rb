# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    trait :hg_brasil do
      slug { 'hg_brasil' }
      name { 'HG Brasil' }
      description { 'HG Brasil is a brazilian company that provides financial APIs.' }
      url { 'https://hgbrasil.com/' }
    end

    trait :br_api do
      slug { 'br_api' }
      name { 'BR API' }
      description { 'BR API is a brazilian company that provides financial APIs.' }
      url { 'https://brapi.dev/' }
    end
  end
end
