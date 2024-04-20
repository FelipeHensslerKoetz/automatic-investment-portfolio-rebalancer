FactoryBot.define do
  factory :partner do
    trait :hg_brasil do
      name { 'HG Brasil' }
      description { 'HG Brasil is a brazilian company that provides financial APIs.' }
      url { 'https://hgbrasil.com/' }
    end

    trait :alpha_vantage do
      name { 'Alpha Vantage' }
      description { 'Alpha Vantage is a company that provides financial APIs.' }
      url { 'https://www.alphavantage.co/' }
    end
  end
end
