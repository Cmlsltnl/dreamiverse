class Image < ActiveRecord::Base
  #
  # Callbacks 
  #
  before_validation :parse_incoming_parameters
  # on_destroy: delete the files: original & resized.

  #
  # Validations
  #
  # validate format: jpg|png|etc

  #
  # Scopes
  #
  scope :by, lambda { |artist| where(artist: artist) }

  # TIDY: where({}) causes unnecessary clone, possible performance hit?
  scope :sectioned, lambda { |section| where(section ? {section: section} : {}) }

  # TODO: currently exact match - substring would be better (esp. notes, tags, etc.)
  # TIDY: can I do this more elegantly? (without the intermediate variable 'results')
  scope :search, lambda { |params|
    # search term
    results = where(['title=? OR artist=? OR album=? OR year=? OR category=? OR genre=? OR notes=? OR tags=?', 
            params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q], params[:q]])
    # filters
    results = results.where(artist: params[:artist]) if params[:artist]
    results = results.where(album: params[:album]) if params[:album]
    results = results.where(title: params[:title]) if params[:title]
    results = results.where(year: params[:year]) if params[:year]
    results = results.where(tags: params[:tags]) if params[:tags]
    # genres
    results = results.where(genre: params[:genres].split(',')) if params[:genres]
    results
  }

  #
  # Class Methods
  #
  attr_accessor :incoming_filename

  def self.albums
    select("distinct(album)").map(&:album)
  end

  def self.artists
    select("distinct(artist)").map(&:artist)
  end
  
  #
  # Instance Methods
  #
  def write(binary_data)
    file = File.open(path, 'wb')
    file.write(binary_data)
  rescue => e
    e
  ensure
    file && file.close
  end

  def resize(size)
    return if resized? size
    
    i = magick
    i.resize size
    i.write path(size) # size is the descriptor.
  end
  
  def resized?(size)
    File.exists? path(size)
  end
  
  # Descriptor is a descriptor of the transformation.
  # Can be a role name or a resize geometry.
  def path(descriptor=nil)
    Rails.public_path + url(descriptor)
  end

  def url(descriptor=nil)
    path = "/images/uploads"
    path += '/originals' unless descriptor
    "#{path}/#{filename(descriptor)}"
  end
  
  def filename(descriptor=nil)
    fname = "#{id}"
    fname += "-#{descriptor}" if descriptor
    "#{fname}.#{format}"
  end
  
  def magick(descriptor=nil)
    MiniMagick::Image.open(path(descriptor))
  end

  # profile :dream_header
  def self.profiles
    {
      dream_header: %w(large small)
    }
  end
  
  def dream_header(activate=true)
    if activate
      dream_header_large
      dream_header_small
    else
      # deactivate - delete the crops
    end
  end
  
  def dream_header?
    profile = :dream_header
    Image::Profiles[profile].all? do |transformation|
      descriptor = [role.to_s, transformation.to_s].join('_').dasherize
      File.exists?(path(descriptor))
    end
  end
  
protected
  def dream_header_large(vertical_offset=nil)
    magick_img = self.magick
    vertical_offset = (magick_img[:height] / 2) - 100 unless vertical_offset
    
    magick_img.combine_options do |i|
      i.resize '720' # width => 720.
      i.crop "x200+0+#{vertical_offset}" # height = 200px, cropped from the center of the image [default].
    end
    magick_img.write(path('dream_header_large'.dasherize))
  end

  def dream_header_small
    
  end
  
  def parse_incoming_parameters
    if @incoming_filename
      self.original_filename = @incoming_filename
      self.format = @incoming_filename.split('.').last unless format
      # Should all formats be jpg?
      # @image.format = "jpg"
      
      self.title = @incoming_filename.split('.')[0...-1].join(' ').titleize unless title
    end
  end
end