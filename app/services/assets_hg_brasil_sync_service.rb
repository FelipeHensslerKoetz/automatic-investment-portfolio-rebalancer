# frozen_string_literal: true

require './lib/hg_brasil/stocks'

class AssetsHgBrasilSyncService
  attr_reader :partner_resource, :asset_prices, :asset_ticker_symbols

  def self.call(asset_ticker_symbols:)
    new(asset_ticker_symbols:).call
  end

  def initialize(asset_ticker_symbols:)
    @asset_ticker_symbols = asset_ticker_symbols
    @partner_resource = PartnerResource.find_by!(slug: :hg_brasil_stock_price)
    @asset_prices = AssetPrice.where(ticker_symbol: asset_ticker_symbols.split(','),
                                     partner_resource:)
  end

  def call
    asset_prices.each do |asset_price|
      next unless asset_price.may_process?

      asset_price.process!
      asset_price.up_to_date! if asset_price.update!(asset_details(asset_price.ticker_symbol))
    rescue StandardError => e
      # TODO: saver error message
      asset_price.fail!
      next
    end
  end

  private

  def fetch_asset_details_by_batch
    @fetch_asset_details_by_batch ||= ::HgBrasil::Stocks.asset_details_batch(asset_ticker_symbols:)
  end

  def asset_details(ticker_symbol)
    asset_detail = fetch_asset_details_by_batch.detect { |asset| asset[:ticker_symbol] == ticker_symbol }

    {
      price: asset_detail.fetch(:price),
      reference_date: asset_detail.fetch(:reference_date)
    }
  end
end
