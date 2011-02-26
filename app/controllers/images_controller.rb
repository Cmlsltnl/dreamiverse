class ImagesController < ApplicationController
  before_filter :require_user, :only => :manage

  def index
    if params.has_key?(:artist) && params.has_key?(:album)
      params[:album] = nil if params[:album] == "null"
      params[:artist] = nil if params[:artist] == ""
      @images = Image.enabled.sectioned(params[:section]).where(artist: params[:artist], album: params[:album])
    elsif params[:q] # search
      @images = Image.enabled.sectioned(params[:section]).search(params) # takes filters etc as well
    elsif params[:ids]
      @images = Image.enabled.where(id: params[:ids].split(','))
    else
      @images = Image.enabled.sectioned(params[:section]).all
    end

    respond_to do |format|
      format.html do
        render :partial => 'image_browser' if request.xhr?
        # otherwise, index.html.erb
      end
      format.json { render :json => @images }
    end
  end
  
  def artists
    image_finder = Image.enabled
    image_finder = image_finder.where(section: params[:section]) if params[:section]
    image_finder = image_finder.where(category: params[:category]) if params[:category]
    image_finder = image_finder.where(genre: params[:genre]) if params[:genre]

    if params[:starts_with]
      @artists = image_finder.where("artist LIKE ?", "#{params[:starts_with]}%").artists
    else
      @artists = {}
      image_finder.each do |image|
        @artists[image.artist] ||= []
        @artists[image.artist] << image unless @artists[image.artist].size >= 6
      end
    end

    respond_to do |format|
      format.html { render(partial: 'images/browser/artists') }
      format.json { render :json => @artists }
    end
  end
  
  def albums
    image_finder = Image.enabled
    image_finder = image_finder.where(section: params[:section]) if params[:section]
    image_finder = image_finder.where(genre: params[:genre]) if params[:genre]

    if params.has_key?(:artist)
      params[:artist] = nil if ["null", "", "Unknown"].include?(params[:artist])
      image_finder = image_finder.where(artist: params[:artist])
      @albums = {}
      image_finder.each do |image|
        @albums[image.album] ||= []
        @albums[image.album] << image
      end
    elsif params[:starts_with]
      @albums = image_finder.where("album LIKE ?", "#{params[:starts_with]}%").albums
    end

    respond_to do |format|
      format.html { render(partial:"images/browser/album") }
      format.json { render :json => @albums }
    end
  end


  def manage
    respond_to do |format|
      format.html # manage.html.erb
      # format.json  { render :json => @images }
    end
  end


  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @image }
    end
  end


  def create
    @image = Image.new(params[:image].merge({
      incoming_filename: params[:qqfile],
      uploaded_by: current_user
    }))

    if !@image.save
      respond_to do |format|
        format.html { render :action => "new", :alert => "Could not upload the file." }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      end
    else
      @image.write(request.body.read)
      respond_to do |format|
        format.html { render :text => 'Image was successfully created.' }
        format.json  { 
          thumb_size = '120x120'
          # @image.resize(thumb_size)
          render :json => {image_url: @image.url(thumb_size), image: @image}.to_json, :status => :created
        }
      end
    end
  rescue => e
    Rails.logger.warn "Error uploading file: #{e.message}"
    respond_to do |format|
      format.html { render :text => "Could not upload the file." }
      format.json  { render :json => e.message, :status => :unprocessable_entity }
    end
  end


  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(params[:image].merge(enabled: true, uploaded_by: current_user))
      respond_to do |format|
        format.html { render :text => 'Image was successfully updated.' }
        format.json  { render json: {type: 'ok', message: 'Image was successfully updated.'} }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.json  { render :json => { type: 'error', errors: @image.errors, status: :unprocessable_entity } }
      end
    end
  end

  def disable
    @image = Image.find(params[:id])
    respond_to do |format|
      if @image.update_attribute(:enabled, false)
        format.html { redirect_to(url_for(@image), :notice => 'Image was disabled.') }
        format.json  { head :ok }
      else
        format.html { redirect_to(url_for(@image), :alert => 'Could not disable the image.') }
        format.json  { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(images_url) }
      format.json  { head :ok }
    end
  end

  # This method is called when a url for a size image that has not yet been generated is requested.
  # It responds with a redirect.
  # We should find a way to show a nice spinner while it is redirecting.
  # This may be a prime place for optimization.
  def resize
    return if detect_infinite_redirect
    
    image = Image.find params[:id]
    image.generate(params[:descriptor], :size => params[:size], :format => params[:format])
    # send_file image.path(params[:size]), {type: params[:format].downcase.to_sym, disposition: 'inline'}
    redirect_to image.url(params[:descriptor], :size => params[:size])
  # rescue => e
  #   Rails.logger.error "Error in Realtime Resize: #{e}"
  #   render_404
  end
  
private
  def detect_infinite_redirect
    (session[:resize_queries] ||= {})[request.path] ||= 0

    if (session[:resize_queries][request.path] += 1) > 5
      render :text => "Error in Realtime Resize."
      Rails.logger.error "Error in Realtime Resize: #{request.url} with params #{params}"
      true
    else
      false
    end
  end
end
