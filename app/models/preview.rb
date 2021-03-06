# -*- encoding : utf-8 -*-
class Preview < ActiveRecord::Base
  belongs_to :media_file

  before_create :set_media_type

  def set_media_type
    self.media_type = Concerns::MediaType.map_to_media_type(self.content_type)
  end

  after_destroy do
    begin
      File.delete(full_path)
    rescue Errno::ENOENT => e
      # might not be an error in some cases
      Rails.logger.warn Formatter.exception_to_log_s(e)
    end
  end

  def full_path
    File.join(THUMBNAIL_STORAGE_DIR, filename[0,1], filename)    
  end

  def size
    File.size(full_path)
  end

end
