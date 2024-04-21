class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.string :kind, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
