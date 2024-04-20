FactoryBot.define do
  factory :currency_parity_exchange_rate do
    currency_parity { create(:currency_parity) }
    exchange_rate { 5.0 }
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
