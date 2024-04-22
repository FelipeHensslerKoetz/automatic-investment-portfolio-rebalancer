# frozen_string_literal: true

class AssetOutdatedError < StandardError
  attr_reader :asset

  def initialize(asset:)
    @asset = asset
    super("Asset with id: #{asset.id} is outdated.")
  end
end
