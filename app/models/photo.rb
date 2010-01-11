class Photo < ActiveRecord::Base
    exif_fu

    has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 10.megabytes,
                 :thumbnails => { :thumb => '150x150>', :small => '640x640>' }

    validates_as_attachment

    belongs_to :gallery

end
