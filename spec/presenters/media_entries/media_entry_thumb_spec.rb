require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'privacy_status_spec'

describe Presenters::MediaEntries::MediaEntryThumb do
  it_responds_to 'privacy_status' do
    let(:resource_type) { :media_entry }
  end
end
