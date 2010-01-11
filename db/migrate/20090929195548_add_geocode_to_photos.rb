class AddGeocodeToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :lat_geo, :string
    add_column :photos, :long_geo, :string
  end

  def self.down
    remove_column :photos, :long_geo
    remove_column :photos, :lat_geo
  end
end
