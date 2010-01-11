class PhotosController < ApplicationController
  require 'rubygems'
  require 'google_geocode'
  before_filter :get_gallery
  before_filter :login_required, :only => ["new", "create", "edit", "update", "destroy"]

  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = Photo.find(params[:id])
    if @photo.exif
      @exif = @photo.exif.split(',') if @photo.exif
    end
    if @photo.lat_geo && @photo.long_geo
      gg = GoogleGeocode.new YAML.load_file(RAILS_ROOT + '/config/gmaps_api_key.yml')[ENV['RAILS_ENV']]
      @map = GMap.new("map_div")
      @map.control_init(:large_map => true) #add :large_map => true to get zoom controls
      @map.center_zoom_init([@photo.lat_geo, @photo.long_geo],15)
      @map.overlay_init(GMarker.new([@photo.lat_geo, @photo.long_geo],:title => @photo.filename))
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = @gallery.photos.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.xml
  def create
    @photo = @gallery.photos.new(params[:photo])
    respond_to do |format|
      if @photo.save
        get_exif
        flash[:notice] = 'Photo was successfully created.'
        format.html { redirect_to(@gallery, @photo) }
        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        get_exif
        flash[:notice] = 'Photo was successfully updated.'
        format.html { redirect_to(@gallery, @photo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to(@gallery) }
      format.xml  { head :ok }
    end
  end

  private
  
  def get_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end

  def get_exif
    exif = [@photo.exif_tag("make"),@photo.exif_tag("model"),@photo.exif_tag("aperture"),@photo.exif_tag("color_space"),@photo.exif_tag("exposure_bias_value"),@photo.exif_tag("exposure_program"),@photo.exif_tag("flash"),@photo.exif_tag("focal_length"),@photo.exif_tag("iso"),@photo.exif_tag("metering_mode"),@photo.exif_tag("shutter_speed_value"),@photo.exif_tag("date_time_original")]

    latitude = @photo.exif_tag("GPSLatitude").split(/\W/)
    longitude = @photo.exif_tag("GPSLongitude").split(/\W/)

    unless latitude.size == 0 && longitude.size == 0
      if latitude.last == "N"
        latitude_quad = 1
      else
        latitude_quad = -1
      end

      if longitude.last == "E"
        longitude_quad = 1
      else
        longitude_quad = -1
      end

      rounding = 1000000

      convert_lat = (latitude_quad * (rounding * (latitude[0].to_i+(latitude[2].to_i.quo(60))+("#{latitude[5]}.#{latitude[6]}".to_i.quo(3600)))).quo(rounding)).to_f
      convert_long = (longitude_quad * (rounding * (longitude[0].to_i+(longitude[2].to_i.quo(60))+("#{longitude[5]}.#{longitude[6]}".to_i.quo(3600)))).quo(rounding)).to_f
    else
      convert_lat = nil
      convert_long = nil
    end

    @photo.update_attributes(:exif => exif.join(','), :lat_geo => convert_lat, :long_geo => convert_long)
    
  end
end
