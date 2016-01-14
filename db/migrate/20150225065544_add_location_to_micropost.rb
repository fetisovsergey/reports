class AddLocationToMicropost < ActiveRecord::Migration
  def change
  	add_column :microposts, :latitude, :float
    add_index  :microposts, :latitude
    add_column :microposts, :longtitude, :float
    add_index  :microposts, :longtitude
    add_column :microposts, :address, :string
    add_index  :microposts, :address
  end
end

