class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :md5
      t.string :label

      t.timestamps
    end
  end
end
