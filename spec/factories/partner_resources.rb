# frozen_string_literal: true

FactoryBot.define do
  factory :partner_resource do
    trait :hg_brasil_stock_price do
      slug { 'hg_brasil_stock_price' }
      name { 'HG Brasil - Stock Price' }
      description { 'API that retrieves brazilian asset prices with a delay between 15 minutes up to 1 hour. The endpoint example is: https://api.hgbrasil.com/finance/stock_price?key=282f20db&symbol=embr3' }
      url { 'https://console.hgbrasil.com/documentation/finance' }
      partner do
        create(:partner, :hg_brasil) unless Partner.exists?(slug: :hg_brasil)
        Partner.find_by(slug: :hg_brasil)
      end
    end
  end
end
