class AssetPrice < ApplicationRecord
  belongs_to :asset
  belongs_to :currency
end
