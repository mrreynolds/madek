# -*- encoding : utf-8 -*-
class EditSession < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :media_resource

  validates_presence_of :user

  default_scope lambda{order(created_at: :desc, id: :asc)}

end
