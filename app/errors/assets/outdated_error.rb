# frozen_string_literal: true

module Assets
  class OutdatedError < StandardError
    attr_reader :asset

    def initialize(asset:)
      @asset = asset
      super("Asset with id: #{asset.id} is outdated.")
    end
  end
end
