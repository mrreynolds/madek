# -*- encoding : utf-8 -*-
 
class MetaDatumMetaTerms < MetaDatum
  has_and_belongs_to_many :meta_terms, 
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :meta_term_id

  SEPARATOR = "; "

  def to_s
    value.map(&:to_s).join(SEPARATOR)
  end

  def value
    meta_terms
  end

  def value=(new_value)    
    new_meta_terms = Array(new_value).flat_map do |v|
      if v.is_a?(MetaTerm)
        v
      elsif UUID_V4_REGEXP.match v 
        MetaTerm.find_by id: v
      else
        raise "Unsupported Value" 
      end
    end
    
    if new_meta_terms.include? nil
      # TODO add to errors doesn't persist
      #errors.add(:value)
      #media_resource.errors.add(:meta_data)
      raise "invalid value"
    else
      meta_terms.clear
      meta_terms << new_meta_terms
    end
  end

end


