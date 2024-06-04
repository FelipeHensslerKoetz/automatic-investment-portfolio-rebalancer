class AddNameIndexOnPartnerResources < ActiveRecord::Migration[6.1]
  def change
    add_index :partner_resources, :name, unique: true
  end
end
