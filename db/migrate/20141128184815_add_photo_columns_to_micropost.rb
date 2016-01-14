class AddPhotoColumnsToMicropost < ActiveRecord::Migration
  def self.up
    add_attachment :microposts, :photo
  end

  def self.down
    remove_attachment :microposts, :photo
  end
end
