# frozen_string_literal: true

FactoryBot.define do
  factory :partner_resource do
    trait :hg_brasil_assets do
      slug { 'hg_brasil_assets' }
      name { 'HG Brasil - Assets' }
      description { 'API that retrieves brazilian asset prices with a delay between 15 minutes up to 1 hour. The endpoint example is: https://api.hgbrasil.com/finance/stock_price&symbol=embr3' }
      url { 'https://console.hgbrasil.com/documentation/finance' }
      partner do
        create(:partner, :hg_brasil) unless Partner.exists?(slug: :hg_brasil)
        Partner.find_by(slug: :hg_brasil)
      end
    end

    trait :hg_brasil_currencies do
      slug { 'hg_brasil_currencies' }
      name { 'HG Brasil - Currencies' }
      description { 'API that retrieves the quotation of currencies and cryptocurrencies. The endpoint example is: https://api.hgbrasil.com/finance/quotations' }
      url { 'https://console.hgbrasil.com/documentation/finance' }
      partner do
        create(:partner, :hg_brasil) unless Partner.exists?(slug: :hg_brasil)
        Partner.find_by(slug: :hg_brasil)
      end
    end

    trait :br_api_assets do
      slug { 'br_api_assets' }
      name { 'BR API - Assets' }
      description { 'API that retrieves the quotation of stocks fiis and etfs. The endpoint example is: https://brapi.dev/api/quote/' }
      url { 'https://brapi.dev/docs/acoes' }
      partner do
        create(:partner, :br_api) unless Partner.exists?(slug: :br_api)
        Partner.find_by(slug: :br_api)
      end
    end

    trait :br_api_currencies do
      slug { 'br_api_currencies' }
      name { 'BR API - Currency' }
      description { 'API that retrieves the quotation of currencies. The endpoint example is: https://brapi.dev/api/v2/currency' }
      url { 'https://brapi.dev/docs/acoes' }
      partner do
        create(:partner, :br_api) unless Partner.exists?(slug: :br_api)
        Partner.find_by(slug: :br_api)
      end
    end
  end
end
