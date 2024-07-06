# frozen_string_literal: true

class AssetSerializer < ActiveModel::Serializer
  attributes :id, :ticker_symbol, :name, :kind

  has_many :asset_prices
end
