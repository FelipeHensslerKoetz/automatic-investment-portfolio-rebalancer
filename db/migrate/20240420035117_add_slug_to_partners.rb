class AddSlugToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :slug, :string, null: false
  end
end
