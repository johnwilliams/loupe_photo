class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :photos, :parent_id
    add_index :photos, :gallery_id
    add_index :galleries, :user_id
    add_index :galleries, :is_active
  end

  def self.down
  end
end
