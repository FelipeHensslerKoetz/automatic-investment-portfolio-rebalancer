# frozen_string_literal: true

require './lib/hg_brasil/stocks'

class AssetsHgBrasilSyncService
  attr_reader :partner_resource, :asset_prices, :ticker_symbols

  def self.call(ticker_symbols:)
    new(ticker_symbols:).call
  end

  def initialize(ticker_symbols:)
    @ticker_symbols = ticker_symbols
    @partner_resource = PartnerResource.find_by!(slug: :hg_brasil_stock_price)
    @asset_prices = AssetPrice.where(ticker_symbol: ticker_symbols.split(','),
                                     partner_resource:)
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
    @fetch_asset_details ||= ::HgBrasil::Stocks.asset_details(ticker_symbols:)
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

    asset_price.up_to_date!
    LogService.create_log(kind: :info, data: info_message(asset_price))
  end

  def fail_asset_price!(asset_price, error)
    asset_price.fail! if asset_price.may_fail?
    LogService.create_log(kind: :error, data: error_message(error))
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
      context: "#{self.class} - ticker_symbols=#{ticker_symbols}",
      message: "Asset price updated successfully: id=#{asset_price.id} ticker_symbol=#{asset_price.ticker_symbol}"
    }
  end
end
