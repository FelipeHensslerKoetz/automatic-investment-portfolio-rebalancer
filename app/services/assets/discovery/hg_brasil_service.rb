# frozen_string_literal: true

require 'hg_brasil/stocks'

module Assets
  module Discovery
    class HgBrasilService
      attr_reader :symbol, :partner_resource, :existing_asset

      def self.call(symbol:)
        new(symbol:).call
      end

      def initialize(symbol:)
        @symbol = symbol&.upcase
        @partner_resource = PartnerResource.find_by!(slug: :hg_brasil_stock_price)
        @existing_asset = Asset.global.find_by('ticker_symbol LIKE :asset',
                                               asset: "%#{symbol}%")
      end

      def call
        return if skip_discovery?

        return create_asset if existing_asset.blank?

        create_asset_price(existing_asset)
      end

      private

      def skip_discovery?
        asset_already_discovered? || asset_details.blank?
      end

      def asset_already_discovered?
        existing_asset.present? && existing_asset.asset_prices.any? do |asset_price|
          asset_price.partner_resource == partner_resource
        end
      end

      def currency
        @currency ||= Currency.find_by!(code: asset_details[:currency])
      end

      def create_asset
        ActiveRecord::Base.transaction do
          @new_asset = Asset.create!(asset_details.except(:price, :reference_date, :currency).merge(custom: false))
          create_asset_price(@new_asset)
        end

        @new_asset
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Error creating asset: #{e.message}")
        nil
      end

      def create_asset_price(target_asset)
        AssetPrice.create!(asset: target_asset,
                           partner_resource:,
                           price: asset_details[:price],
                           last_sync_at: Time.zone.now,
                           ticker_symbol: asset_details[:ticker_symbol],
                           currency:,
                           reference_date: asset_details[:reference_date])
        nil
      end

      # TODO: treat exception
      def asset_details
        @asset_details ||= HgBrasil::Stocks.asset_details(symbol:)
      end
    end
  end
end
