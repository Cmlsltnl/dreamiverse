require 'test_helper'


class DreamImporterTest < ActiveSupport::TestCase
  setup do
    Image.stubs( :write ).
      returns(true)
    Legacy::User.stubs( :image_id).
      returns(1)
    
  end
  
  test 'dream import' do
    Legacy::Dream.stubs(:user_id).returns(1)
    
    Legacy::Dream.offset(rand(1500)).limit(100).each do |dream|
      entry = Migration::DreamImporter.new(dream).migrate
      entry.save!
      assert_equal entry.title, dream.title
      assert_equal entry.body, dream.description
      assert_equal entry.user.username, dream.user.username
      assert_equal entry.created_at, dream.created_at
      # assert_equal entry.whats.map(&:name), 
      #   dream.customTagsList.split(',').compact.map(&:strip).map(&:downcase).
      #     map{|t| t.slice(0...20)}.reject{|t| t.size < 3}.reject{|t| Tag::BlacklistWords[t]}.uniq
      assert_equal entry.book_list.split(','), dream.user_series.map(&:option).map(&:title)
    end
    debugger
    1
  end
  
  test "duplicate tags" do
    # dreams about the sky
    sky_dreams = Legacy::Dream.where(["customTagsList LIKE ?", '%,sky,%'])
    puts sky_dreams.map(&:customTagsList).join(' ::: ')
    2.times do
      dream = sky_dreams[ rand(sky_dreams.count) ]
      entry = Migration::DreamImporter.new(dream).migrate
    end
    assert_equal 1, What.where(name: 'sky').count
  end

end
