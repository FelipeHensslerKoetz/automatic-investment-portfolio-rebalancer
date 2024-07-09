class AddAssetIdAndPartnerResourceIdUniqueIndexOnAssetPrices < ActiveRecord::Migration[6.1]
  def change
    add_index :asset_prices, [:asset_id, :partner_resource_id], unique: true
  end
end
