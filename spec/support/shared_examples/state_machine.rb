shared_examples 'state machine' do
  it { is_expected.to have_field(:state).of_type(String).with_default_value_of('processing') }

  describe '#processing?' do
    it 'returns true if state equals "processing"' do
      subject.state = 'processing'
      is_expected.to be_processing
    end

    it 'returns false if state does not equal "processing"' do
      subject.state = 'safe'
      is_expected.not_to be_processing
    end
  end

  describe '#safe?' do
    it 'returns true if state equals "safe"' do
      subject.state = 'safe'
      is_expected.to be_safe
    end

    it 'returns false if state does not equal "safe"' do
      subject.state = 'malicious'
      is_expected.not_to be_safe
    end
  end
end
