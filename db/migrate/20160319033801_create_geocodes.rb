class CreateGeocodes < ActiveRecord::Migration[5.0]
  def change
    create_table :geocodes do |t|
      t.float :latitude
      t.float :longitude
      t.string :locality
      t.string :country

      t.timestamps
    end
  end
end
