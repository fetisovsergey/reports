class AddAboutToUsers < ActiveRecord::Migration
  def change
    add_column :users, :about, :string
    #add_index  :users, :about
    add_column :users, :city, :string
    add_index  :users, :city
    add_column :users, :realname, :string
    add_index  :users, :realname
    add_column :users, :surname, :string
    add_index  :users, :surname
    add_column :users, :weblink, :string
    #add_index  :users, :weblink
  end
end
