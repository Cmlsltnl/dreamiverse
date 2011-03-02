class EntriesController < ApplicationController
  before_filter :require_user, :only => [:new, :edit, :stream]
  before_filter :query_username, :except => [:stream]

  def entry_list
  end
  
  def index
    redirect_to(user_entries_path(@user.username)) unless params[:username]
    
    session[:lens] = :field
    session[:filters] = params[:filters].merge({user: @user})

    # entry_list
    @entries = Entry.list(current_user, session[:lens], session[:filters])
    
    @user.starlight.add( 1 ) if unique_hit?

  end

  def show
    entry_list # I don't love having to generate the whole list here.
    i = @entries.index{|e| e.id == params[:id].to_i } || 0
    @previous = @entries[i-1]
    @next = @entries[i+1] || @entries[0]
    @entry = @entries[i]
    # @entry = Entry.find params[:id]
    redirect_to(user_entry_path(@entry.user.username, @entry)) unless params[:username]
    deny and return unless user_can_access?

    @comments = @entry.comments.order('created_at DESC') # .limit(10)
    @page_title = @entry.title
    
    if unique_hit?
      @entry.starlight.add( 1 )
      @entry.user.starlight.add( 1 )
    end
  end
  
  def new
    @entry = Entry.new
  end
  
  def edit
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
    render :new
  end

  def create
    what_names = params[:what_tags] || []
    whats = what_names.map {|name| What.find_or_create_by_name name }

    new_entry = current_user.entries.create!(params[:entry].merge(
      whats: whats
    ))
    redirect_to user_entry_path(current_user.username, new_entry)
  end
  
  def update
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?

    what_names = params[:what_tags] || []
    whats = what_names.map {|name| What.find_or_create_by_name name }
    whats.each { |what| @entry.add_what_tag(what) }
    
    @entry.update_attributes( params[:entry] )
    redirect_to :action => :show, :id => params[:id]
  end
  
  def destroy
    @entry = Entry.find params[:id]
    deny and return unless user_can_write?
    
    @entry.destroy
    redirect_to :index
  end

  def stream
    session[:lens] = :stream
    session[:filters] = params[:filters]

    @user = current_user

    @entries = Entry.list(current_user, session[:lens], session[:filters])
    
    # not my own dreams
    # @entries = @entries.where(:user_id ^ current_user.id)
    
    if request.xhr?
      thumbs_html = ""
      @entries.each { |entry| thumbs_html += render_to_string(:partial => 'thumb_1d', :locals => {:entry => entry}) }
      
      
      render :text => thumbs_html
    end
  end

  def bedsheet
    @entry = Entry.find(params[:id])
    @entry.view_preference.image = Image.find(params[:bedsheet_id])
    @entry.save!
    render :json => "entry bedsheet updated"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end

  protected

  # sets @user to be either params[:username]'s user or current_user
  # Redirect to / if neither param nor current_user.
  def query_username
    @user = params[:username] ? User.find_by_username( params[:username] ) : current_user
    redirect_to root_path, :alert => "no user #{params[:username]}" and return unless @user
  end
  
  
  # requires @entry be set
  def user_can_access?
    @entry.everyone? || (current_user && current_user.can_access?(@entry))
  end

  # requires @entry be set
  def user_can_write?
    (current_user == @entry.user)
  end

  def deny
    if params[:username]
      redirect_to user_entries_path(params[:username]), :alert => "Access denied to this entry."
    else
      redirect_to :root, :alert => "Access denied to this entry."
    end
  end
    
end
