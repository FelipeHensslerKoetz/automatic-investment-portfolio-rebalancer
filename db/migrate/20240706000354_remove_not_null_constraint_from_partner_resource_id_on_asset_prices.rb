class RemoveNotNullConstraintFromPartnerResourceIdOnAssetPrices < ActiveRecord::Migration[6.1]
  def change
    change_column_null :asset_prices, :partner_resource_id, true
  end
end
