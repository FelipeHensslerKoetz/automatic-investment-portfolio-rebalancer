# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    trait :hg_brasil do
      slug { 'hg_brasil' }
      name { 'HG Brasil' }
      description { 'HG Brasil is a brazilian company that provides financial APIs.' }
      url { 'https://hgbrasil.com/' }
    end
  end
end
