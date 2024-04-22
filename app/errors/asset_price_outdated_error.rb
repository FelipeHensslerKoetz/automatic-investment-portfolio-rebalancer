# frozen_string_literal: true

class AssetPriceOutdatedError < StandardError
  attr_reader :asset_price

  def initialize(asset_price:)
    @asset_price = asset_price
    super("AssetPrice with id: #{asset_price.id} is outdated.")
  end
end
