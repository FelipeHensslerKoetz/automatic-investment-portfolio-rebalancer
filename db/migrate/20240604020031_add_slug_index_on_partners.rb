class AddSlugIndexOnPartners < ActiveRecord::Migration[6.1]
  def change
    add_index :partners, :slug, unique: true
  end
end
