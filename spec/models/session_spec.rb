require 'spec_helper'

RSpec.describe Session, type: :model do
  it { is_expected.to have_field(:browser).of_type(String) }
  it { is_expected.to have_field(:safe_sites_count).of_type(Integer).with_default_value_of(0) }
  it { is_expected.to have_field(:malicious_sites_count).of_type(Integer).with_default_value_of(0) }

  it { is_expected.to have_many(:sites).of_type(Site) } # .with_foreign_key(:key)

  it { is_expected.to validate_presence_of(:browser) }

  describe '#key' do
    it 'has unique key' do
      expect(subject.key).not_to eq(Session.new.key)
    end
  end

  describe '#as_json' do
    it 'returns hash with key as id and nested hash of attributes' do
      expect(subject.as_json).to eq({
        type: 'sessions',
        id: subject.key,
        attributes: {
          safe_sites_count: 0,
          malicious_sites_count: 0
        }
      })
    end
  end
end
