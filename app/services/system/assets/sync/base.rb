# frozen_string_literal: true

module System
  module Assets
    module Sync
      class Base
        attr_reader :ticker_symbols, :partner_resource, :asset_prices

        def self.call
          new(ticker_symbols:, partner_resource_slug:).call
        end

        def initialize(ticker_symbols:, partner_resource_slug:)
          @ticker_symbols = ticker_symbols
          @partner_resource = PartnerResource.find_by!(slug: partner_resource_slug)
          @asset_prices = AssetPrice.where(ticker_symbol: ticker_symbols.split(','),
                                           partner_resource:,
                                           status: 'scheduled')
        end

        def call
          asset_prices.each do |asset_price|
            process_asset_price!(asset_price)
          rescue StandardError => e
            fail_asset_price!(asset_price, e)
            next
          end
        end

        private

        def fetch_asset_details
          raise NotImplementedError
        end

        def asset_details(ticker_symbol)
          asset_detail = fetch_asset_details.detect { |asset| asset[:ticker_symbol] == ticker_symbol }

          {
            price: asset_detail.fetch(:price),
            reference_date: asset_detail.fetch(:reference_date)
          }
        end

        def process_asset_price!(asset_price)
          asset_price.process!

          return unless asset_price.update!(asset_details(asset_price.ticker_symbol))

          asset_price.update!(error_message: nil) if asset_price.error_message.present?
          asset_price.up_to_date!
          System::Logs::CreatorService.create_log(kind: :info, data: info_message(asset_price))
        end

        def fail_asset_price!(asset_price, error)
          asset_price.fail!
          asset_price.update!(error_message: error.message)
          System::Logs::CreatorService.create_log(kind: :error, data: error_message(error))
        end

        def error_message(error)
          {
            context: "#{self.class} - ticker_symbols=#{ticker_symbols}",
            message: error.message,
            backtrace: error.backtrace
          }
        end

        def info_message(asset_price)
          {
            context: "#{self.class} - ticker_symbol=#{asset_price.ticker_symbol}",
            message: 'Asset price updated',
            asset_price_id: asset_price.id
          }
        end
      end
    end
  end
end
