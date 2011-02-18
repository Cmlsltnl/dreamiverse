# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


if Image.where(:title => "Default Avatar").count == 0
  avatar_filename = "avatar_lg.jpg"
  default_avatar_image = Image.create({
    :section => "Avatar",
    :title => "Default Avatar",
    :artist => "Andrew Jones",
    :incoming_filename => avatar_filename
  })
  
  default_avatar_image.write( File.open("#{Rails.root}/db/#{avatar_filename}", 'r').read )
end
