require 'spec_helper'

RSpec.describe Script, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it_behaves_like 'state machine'
  it { is_expected.to have_index_for(site_id: 1) }

  it { is_expected.to belong_to(:site).of_type(Site) }
  it { is_expected.to belong_to(:source_code).of_type(SourceCode) }

  it { is_expected.to validate_presence_of(:name) }

  describe '#analyze_source_code!' do
    subject { create(:script) }
    before { allow_any_instance_of(SourceCode).to receive(:sleep).with(60) }

    it 'analyzes source code by type and content and assigns state' do
      subject.analyze_source_code!
      is_expected.to be_safe
    end
  end
end
