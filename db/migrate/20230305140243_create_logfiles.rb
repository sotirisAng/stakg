class CreateLogfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :logfiles do |t|
      t.string :name
      t.string :pilot_type
      t.string :file_type
      # t.references :file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
