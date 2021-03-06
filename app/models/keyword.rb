# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base

  # required for with_count_for_accessible_media_resources
  include Concerns::ResourcesThroughPermissions

  belongs_to :user
  belongs_to :meta_datum
  belongs_to :keyword_term

  before_create do
    keyword_term.update!(creator: user) unless keyword_term.creator.present?
  end

  def to_s
    "#{keyword_term}"
  end

  scope :with_count, lambda{
    select("keyword_term_id, COUNT(keyword_term_id) AS count") \
      .group("keywords.keyword_term_id").order("count DESC") }

  scope :with_count_for_accessible_media_resources, lambda{ |user = nil|
    with_count.joins(meta_datum: :media_resource) \
      .accessible_by_user(user,:view) }

#######################################

  scope :hacky_search, lambda { |query|
    if query.blank?
      where(nil)
    else
      search_term= "%#{query}%"
      joins(:keyword_term).where("keyword_terms.term ilike ?","%#{query}%")
    end
  }

end
