FactoryBot.define do
  factory :asset_price do
    asset { create(:asset) }
    ticker_symbol { 'code' }
    currency { create(:currency) }
    price { 9.99 }
    last_sync_at { Time.zone.now }
    reference_date { Time.zone.now }

    trait :updated do
      status { 'updated' }
    end

    trait :scheduled do
      status { 'scheduled' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :outdated do
      status { 'outdated' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :with_hg_brasil_stock_price_partner_resource do
      partner_resource do
        create(:partner_resource, :hg_brasil_stock_price) unless PartnerResource.exists?(name: 'HG Brasil - Stock Price')
        PartnerResource.find_by(name: 'HG Brasil - Stock Price')
      end
    end
  end
end
