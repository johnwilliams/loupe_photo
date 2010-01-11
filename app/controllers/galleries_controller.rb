class GalleriesController < ApplicationController
  # GET /galleries
  # GET /galleries.xml
  before_filter :login_required, :only => ["new", "create", "edit", "update", "destroy"]
  
  def index
    @page_title = APP_CONFIG[:site_name] + " - Galleries"
    if current_user
      @galleries = Gallery.paginate :page => params[:page], :order => 'updated_at DESC', :per_page => 10
    else
      @galleries = Gallery.paginate_all_by_is_active true, :page => params[:page], :order => 'updated_at DESC', :per_page => 10
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @galleries }
    end
  end

  # GET /galleries/1
  # GET /galleries/1.xml
  def show
    @gallery = Gallery.find(params[:id])
    @photos = @gallery.photos.paginate :page => params[:page], :order => 'updated_at DESC', :per_page => 30
    @page_title = APP_CONFIG[:site_name] + " - " + @gallery.name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @gallery }
    end
  end

  # GET /galleries/new
  # GET /galleries/new.xml
  def new
    @gallery = current_user.galleries.new
    @page_title = APP_CONFIG[:site_name] + " - New Gallery"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @gallery }
    end
  end

  # GET /galleries/1/edit
  def edit
    @gallery = Gallery.find(params[:id])
    @page_title = APP_CONFIG[:site_name] + " - Edit Gallery - " + @gallery
  end

  # POST /galleries
  # POST /galleries.xml
  def create
    @gallery = current_user.galleries.new(params[:gallery])

    respond_to do |format|
      if @gallery.save
        flash[:notice] = 'Gallery was successfully created.'
        format.html { redirect_to(@gallery) }
        format.xml  { render :xml => @gallery, :status => :created, :location => @gallery }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /galleries/1
  # PUT /galleries/1.xml
  def update
    @gallery = Gallery.find(params[:id])

    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        flash[:notice] = 'Gallery was successfully updated.'
        format.html { redirect_to(@gallery) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /galleries/1
  # DELETE /galleries/1.xml
  def destroy
    @gallery = Gallery.find(params[:id])
    @gallery.destroy

    respond_to do |format|
      format.html { redirect_to(galleries_url) }
      format.xml  { head :ok }
    end
  end
end
