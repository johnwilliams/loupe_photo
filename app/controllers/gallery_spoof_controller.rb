class GallerySpoofController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :index

  def index
    if params[:g2_form]

      if params[:g2_form][:cmd].downcase == "login"
        user = User.authenticate(params[:g2_form][:uname], params[:g2_form][:password])
        if user
          self.current_user = user
          render :text => "#__GR2PROTO__\nserver_version=2.13\ndebug_core_version=7,54\ndebug_module_version=1.0.17\nstatus=0\nstatus_text=Login successful.\ndebug_user=#{user.login}\ndebug_time=0.091s\nauth_token=798dfu97fd"
        else
          render :text => "#__GR2PROTO__\nstatus=201\nstatus_text=Password incorrect.\ndebug_user=guest"
        end
      end

      if params[:g2_form][:cmd].downcase == "fetch-albums-prune"
        user = User.authenticate(params[:g2_form][:uname], params[:g2_form][:password])
        if user
          @galleries = Gallery.find(:all, :order => 'name ASC')
          response = "#__GR2PROTO__\ndebug_time_albumids=0.094s\ndebug_time_entities=0.119s\ndebug_time_permissions=0.121s\n"
          @galleries.each_with_index do |gallery, index|
            response = response + "album.name.#{index + 1}=#{gallery.id}\nalbum.title.#{index + 1}=#{gallery.name}\nalbum.summary.#{index + 1}=\nalbum.parent.#{index + 1}=0\nalbum.perms.add.#{index + 1}=true\nalbum.perms.write.#{index + 1}=true\nalbum.perms.del_alb.#{index + 1}=true\nalbum.perms.create_sub.#{index + 1}=true\nalbum.info.extrafields.#{index + 1}=Summary,Description\n"
          end
          response = response + "can_create_root=true\nalbum_count=#{@galleries.size}\nstatus=0\nstatus_text=Fetch-albums successful.\ndebug_user=#{user.login}\ndebug_time=0.131s\nauth_token=c232b2d1b588"
        end
        render :text => response
      end

      if params[:g2_form][:cmd].downcase == "new-album"
        user = User.authenticate(params[:g2_form][:uname], params[:g2_form][:password])
        if user
          @gallery = user.galleries.new
          @gallery.name = params[:g2_form][:newAlbumTitle]
          response = "#__GR2PROTO__"
          if @gallery.save
            response = response + "\nalbum_name=#{@gallery.id}\nstatus=0\nstatus_text=New-album successful.\ndebug_user=#{user.login}\ndebug_time=0.188s\nauth_token=798dfu97fd"
          end
          render :text => response
        end
      end
      
      if params[:g2_form][:cmd].downcase == "add-item"
        user = User.authenticate(params[:g2_form][:uname], params[:g2_form][:password])
        response = "#__GR2PROTO__"
        if user
          @gallery = Gallery.find(params[:g2_form][:album_id])
          @photo = @gallery.photos.new(:uploaded_data => params[:g2_userfile])
          if @photo.save
            if @photo.exif_tag("createdate").length > 1
              exif = [@photo.exif_tag("make"),@photo.exif_tag("model"),@photo.exif_tag("aperture"),@photo.exif_tag("color_space"),@photo.exif_tag("exposure_bias_value"),@photo.exif_tag("exposure_program"),@photo.exif_tag("flash"),@photo.exif_tag("focal_length"),@photo.exif_tag("iso"),@photo.exif_tag("metering_mode"),@photo.exif_tag("shutter_speed_value"),@photo.exif_tag("date_time_original")]
              @photo.update_attributes(:exif => exif.join(','))
            end
            response = response + "#__GR2PROTO__\nstatus=0\nstatus_text=Add photo successful.\nitem_name=#{@photo.id}.\ndebug_user=#{user.login}\ndebug_time=1.043s\nauth_token=533b38865c97"
          else
            response = response + "Failed"
          end
        end
        render :text => response
      end
      
    end
  end

end
