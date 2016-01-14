class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
    	t.string :address
      t.integer :user_id
      t.float :latitude
      t.float :longtitude
      t.timestamps
    end
    add_index :locations, :user_id, unique: true
    add_index :locations, :latitude
    add_index :locations, :longtitude
    add_index :locations, :address
    add_index :locations, [:latitude, :longtitude]
  end
end
