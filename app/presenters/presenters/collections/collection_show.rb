module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::Resources::ResourceShow

      def highlights_thumbs
        @resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me, @user) }
      end

      def poly_resources
        {
          media_entries:
            @resource \
              .media_entries
              .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me, @user) },

          collections:
            @resource \
              .collections
              .map { |c| Presenters::Collections::CollectionThumb.new(c, @user) },

          filter_sets:
            @resource \
              .filter_sets
              .map { |fs| Presenters::FilterSets::FilterSetThumb.new(fs, @user) },
        }
      end


    end
  end
end
