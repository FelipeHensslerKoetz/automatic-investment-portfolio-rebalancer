class CreatePartnerResources < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_resources do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :description
      t.string :url
      t.references :partner, null: false, foreign_key: true

      t.timestamps
    end

    add_index :partner_resources, :slug, unique: true
  end
end
