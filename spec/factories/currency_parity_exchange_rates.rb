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

    trait :with_hg_brasil_stock_price_partner_resource do
      partner_resource do
        create(:partner_resource, :hg_brasil_stock_price) unless PartnerResource.exists?(slug: 'hg_brasil_stock_price')
        PartnerResource.find_by(slug: 'hg_brasil_stock_price')
      end
    end

    trait :with_hg_brasil_quotation_partner_resource do
      partner_resource do
        create(:partner_resource, :hg_brasil_quotation) unless PartnerResource.exists?(slug: 'hg_brasil_quotation')
        PartnerResource.find_by(slug: 'hg_brasil_quotation')
      end
    end

    trait :with_br_api_currency_partner_resource do
      partner_resource do
        create(:partner_resource, :br_api_currency) unless PartnerResource.exists?(slug: 'br_api_currency')
        PartnerResource.find_by(slug: 'br_api_currency')
      end
    end
  end
end
