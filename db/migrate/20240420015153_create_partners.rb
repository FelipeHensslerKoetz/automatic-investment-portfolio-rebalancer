class CreatePartners < ActiveRecord::Migration[6.1]
  def change
    create_table :partners do |t|
      t.string :name, null: false
      t.string :description
      t.string :url

      t.timestamps
    end

    add_index :partners, :name, unique: true
  end
end
