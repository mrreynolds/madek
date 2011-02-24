# -*- encoding : utf-8 -*-
#= MetaKey
#
# Holds the set of basic meta data keys
class MetaKey < ActiveRecord::Base

  has_many :meta_data
  has_many :media_entries, :through => :meta_data, :uniq => true
  has_many :meta_key_definitions do
    def for_context(context)
      @meta_key_definitions ||= {}
      @meta_key_definitions[context.id] ||= scoped_by_meta_context_id(context).first
    end
  end
  has_many :meta_contexts, :through => :meta_key_definition
  has_and_belongs_to_many :meta_terms, :class_name => "Meta::Term",  # TODO enforce object_type="Meta::Term" if meta_terms
                                       :join_table => :meta_keys_meta_terms,
                                       :association_foreign_key => :meta_term_id
  accepts_nested_attributes_for :meta_terms, :allow_destroy => true, :reject_if => proc { |attributes| LANGUAGES.all? {|l| attributes[l].blank? } }

  validates_uniqueness_of :label

  #old#precedence problem# default_scope order(:label)
  scope :with_meta_data, joins(:meta_data).group(:id)

########################################################

  before_save do |record|
    record.object_type = nil if record.object_type.blank? 
  end

  def to_s
    label #.capitalize
  end

########################################################

  #working here#9
  def key_map_for(context)
    d = meta_key_definitions.for_context(context)
    d.key_map if d
  end

########################################################

  def self.all_cached
    Rails.cache.fetch("meta_keys", :expires_in => 10.minutes) do
      all
    end    
  end

########################################################

# Return a meta_key matching the provided key-map
#
# args: a keymap (fully namespaced)
# returns: a meta_key
#
# NB: If no meta_key matching the key-map is found, it is created 
# along with a new meta_key_definition (albeit with minimal label and description data)
  def self.meta_key_for(key_map) # TODO, context = nil)
    # do we really need to find by context here?
#    mk =  if context.nil?
#            MetaKeyDefinition.find_by_key_map(key_map).try(:meta_key)
#          else
#            context.meta_key_definitions.find_by_key_map(key_map).try(:meta_key)
#          end

    mk = MetaKeyDefinition.where("key_map LIKE ?", "%#{key_map}%").first.try(:meta_key)

    if mk.nil?
      entry_name = key_map.split(':').last.underscore.gsub(/[_-]/,' ')
      mk = MetaKey.find_by_label(entry_name)
    end
      # we have to create the meta key, since it doesnt exist
    if mk.nil?
      mk = MetaKey.find_or_create_by_label(entry_name)
      mc = MetaContext.io_interface

      # Would be nice to build some useful info into the meta_field for this new creation.. but we know nothing about it apart from its namespace:tagname
      meta_field = { :label => {:en_GB => "", :de_CH => ""},
                :description => {:en_GB => "", :de_CH => ""}
              }

      mk.meta_key_definitions.create( :meta_context => mc,
                                      :meta_field => meta_field,
                                      :key_map => key_map,
                                      :key_map_type => nil,
                                      :position => mc.meta_key_definitions.maximum("position") + 1 )
    end
    mk
  end

  def self.object_types
    where("object_type IS NOT NULL").group(:object_type).collect(&:object_type).sort
  end
  
########################################################

  # overriding framework method in order to have an identity map
  @@identity_map ||= {}
  def self.find(*args)
    record = if args.first.is_a?(Fixnum) # or !!args.first.match(/\A[+-]?\d+\Z/) # TODO path to String#is_numeric? method
               @@identity_map[args.first]
             elsif args.size > 1 and args.last[:conditions] and args.last[:conditions][:label] 
               @@identity_map[args.last[:conditions][:label]]
             end
    unless record
      record = super(*args)
      Array(record).each do |r|
        @@identity_map[r.id] = @@identity_map[r.label] = r
      end
    end
    record
  end

########################################################

#old#
#  def self.init(reset = false)
#    puts "Metakey::init"
#    return 0 unless reset or count == 0
#    delete_all
#
#    keys = YAML.load(File.read("#{METADATA_CONFIG_DIR}/key.yml"))
#
#    keys.each do |key|
#      meta_terms = key.delete("meta_terms")
#      k = create(key)
#      k.meta_terms.create(meta_terms) if meta_terms
#    end
#
#    return count
#  end

end
