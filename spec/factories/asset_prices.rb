# frozen_string_literal: true

FactoryBot.define do
  factory :asset_price do
    asset { create(:asset) }
    ticker_symbol { 'code' }
    currency { create(:currency) }
    price { 9.99 }
    last_sync_at { Time.zone.now }
    reference_date { Time.zone.now }

    trait :pending do
      status { 'pending' }
    end

    trait :updated do
      status { 'updated' }
    end

    trait :scheduled do
      status { 'scheduled' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :with_hg_brasil_assets_partner_resource do
      partner_resource do
        create(:partner_resource, :hg_brasil_assets) unless PartnerResource.exists?(slug: 'hg_brasil_assets')
        PartnerResource.find_by(slug: 'hg_brasil_assets')
      end
    end

    trait :with_br_api_assets_partner_resource do
      partner_resource do
        create(:partner_resource, :br_api_assets) unless PartnerResource.exists?(slug: 'br_api_assets')
        PartnerResource.find_by(slug: 'br_api_assets')
      end
    end
  end
end
