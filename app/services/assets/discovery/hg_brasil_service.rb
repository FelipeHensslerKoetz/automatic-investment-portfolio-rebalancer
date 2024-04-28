# frozen_string_literal: true

require './lib/hg_brasil/stocks'

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

        discover_asset
      rescue StandardError => e
        LogService.create_log(kind: :error, data: error_message(e))
        nil
      end

      private

      def discover_asset
        existing_asset.blank? ? create_asset : create_asset_price(existing_asset)
      end

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
          @new_asset
        end
      end

      def create_asset_price(target_asset)
        asset_price = AssetPrice.create!(asset: target_asset,
                                         partner_resource:,
                                         price: asset_details[:price],
                                         last_sync_at: Time.zone.now,
                                         ticker_symbol: asset_details[:ticker_symbol],
                                         currency:,
                                         reference_date: asset_details[:reference_date])

        LogService.create_log(kind: :info, data: new_asset_price_message(asset_price))

        nil
      end

      def asset_details
        @asset_details ||= HgBrasil::Stocks.asset_details(symbol:)
      end

      def error_message(error)
        {
          context: "#{self.class} - symbol=#{symbol}",
          error: error.message,
          backtrace: error.backtrace
        }
      end

      def new_asset_price_message(asset_price)
        {
          context: "#{self.class} - symbol=#{symbol}",
          message: "New AssetPrice created id=#{asset_price.id} symbol=#{asset_price.ticker_symbol}"
        }
      end
    end
  end
end
