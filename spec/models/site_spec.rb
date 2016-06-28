require 'spec_helper'

RSpec.describe Site, type: :model do
  it { is_expected.to have_field(:url).of_type(String) }
  it_behaves_like 'state machine'
  it { is_expected.to have_index_for(session_id: 1) }
  it { is_expected.to have_index_for(session_id: 1, url: 1).with_options(unique: true) }

  it { is_expected.to belong_to(:session).of_type(Session) }
  it { is_expected.to have_many(:scripts).of_type(Script) }

  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_uniqueness_of(:url).scoped_to(:session_id) }

  describe '#as_json' do
    subject { Site.new(url: 'http://example.com') }

    it 'returns hash with key as id and nested hash of attributes' do
      expect(subject.as_json).to eq({
        type: 'sites',
        id: subject.id.to_s,
        attributes: {
          url: 'http://example.com',
          state: 'processing'
        }
      })
    end
  end
end
