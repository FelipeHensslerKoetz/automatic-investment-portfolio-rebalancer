class AddCurrencyParityIdAndPartnerResourceIdUniqueIndexOnCurrencyParityExchangeRates < ActiveRecord::Migration[6.1]
  def change
    add_index :currency_parity_exchange_rates, [:currency_parity_id, :partner_resource_id], name: 'currency_parity_and_partner_resource_index',unique: true
  end
end
