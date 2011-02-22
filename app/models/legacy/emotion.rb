class Legacy::Emotion < Legacy::Base
  set_table_name 'dreamEmotion'

  belongs_to 'dream', {foreign_key: "dreamId", class_name: "Legacy::Dream"}
  belongs_to 'option', {foreign_key: 'dreamEmotionOptionId', class_name: "Legacy::EmotionOption"}

  def intensity
    setting / 10
  end
  def noun_id
    emotion = Emotion.find_by_name option.title
    if emotion.nil?
      emotion = Migration::EmotionImporter.new(option).migrate
      emotion.save!
    end
    emotion.id
  end
  def noun_type
    'Emotion'
  end
  
  def entry_id
    # combination of created_at and title
    entry = Entry.where(created_at: dream.created_at, title: dream.title).first
    # raise "You must migrate Dreams first: dream: #{dream.inspect}" if entry.blank?
    if entry.blank?
      entry = Migration::DreamImporter.new(dream).migrate
      entry.save!
    end
    entry.id
  end
end
