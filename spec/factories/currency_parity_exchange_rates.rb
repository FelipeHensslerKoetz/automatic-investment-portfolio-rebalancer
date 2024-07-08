# frozen_string_literal: true

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

    trait :failed do
      status { 'failed' }
    end

    trait :pending do
      status { 'pending' }
    end

    trait :with_hg_brasil_currencies_partner_resource do
      partner_resource do
        create(:partner_resource, :hg_brasil_currencies) unless PartnerResource.exists?(slug: 'hg_brasil_currencies')
        PartnerResource.find_by(slug: 'hg_brasil_currencies')
      end
    end

    trait :with_br_api_currencies_partner_resource do
      partner_resource do
        create(:partner_resource, :br_api_currencies) unless PartnerResource.exists?(slug: 'br_api_currencies')
        PartnerResource.find_by(slug: 'br_api_currencies')
      end
    end
  end
end
