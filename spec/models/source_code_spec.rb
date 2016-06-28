require 'spec_helper'

RSpec.describe SourceCode, type: :model do
  it { is_expected.to have_field(:type).of_type(String) }
  it { is_expected.to have_field(:content).of_type(String) }
  it_behaves_like 'state machine'

  it { is_expected.to have_many(:scripts).of_type(Script) }

  it { is_expected.to validate_inclusion_of(:type).to_allow('html', 'javascript') }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_uniqueness_of(:content).scoped_to(:type) }

  describe '#analyze!' do
    it 'uses sleep command for the delay' do
      subject.state = 'processing'
      subject.content = ''
      expect(subject).to receive(:sleep).with(60)
      subject.analyze!
    end

    it 'assigns state to "safe" if the content length is even' do
      subject.state = 'processing'
      subject.content = '0123456789'
      allow(subject).to receive(:sleep).with(60)
      subject.analyze!
      expect(subject).to be_safe
    end

    it 'assigns state to "malicious" if the content length is odd' do
      subject.state = 'processing'
      subject.content = '123'
      allow(subject).to receive(:sleep).with(60)
      subject.analyze!
      expect(subject.state).to eq('malicious')
    end


    it 'does not process content again if it is already processed' do
      subject.state = 'safe'
      expect(subject).not_to receive(:sleep)
      subject.analyze!
    end
  end
end
