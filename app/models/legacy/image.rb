class Legacy::Image < Legacy::Base
  set_table_name 'image'

  def find_corresponding_image
    
  end
  belongs_to :user, {foreign_key: "userId", class_name: "Legacy::User"}

  has_many :dream_images, {foreign_key: 'imageId', class_name: 'Legacy::DreamImage'}
  has_many :dreams, {through: :dream_images}
  def self.valid
    images = self.all
    images.reject!{|i| !i.avatar? && i.dreams.blank?}
    images.select!{|i| i.filename =~ /^.*\.(png|jpg|gif|jpeg|JPG|PNG)$/}
  end

  def avatar?
    if name.blank?
      return true
    elsif name == '_64'
      return false
    else
      raise 'unknown name value for image!'
    end
  end
  
  def filename
    if avatar?
      fileLocation
    else
      fileLocation.split('/').last
    end
  end
  def original_filename
    filename
  end
  def path
    if avatar?
      "avatar/#{self.user.id}/#{self.filename}/#{self.filename}"
    else
      "dream-galleries/#{self.dreams.first.id}/original/#{self.filename}"
    end
  end

  def uploaded_by_id
    user.find_or_create_corresponding_user.id
  end
end
