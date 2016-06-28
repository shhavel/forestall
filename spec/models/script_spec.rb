require 'spec_helper'

RSpec.describe Script, type: :model do
  it { is_expected.to have_field(:name).of_type(String) }
  it_behaves_like 'state machine'

  it { is_expected.to belong_to(:site).of_type(Site) }
  it { is_expected.to belong_to(:source_code).of_type(SourceCode) }

  it { is_expected.to validate_presence_of(:name) }

  describe '#analyze_source_code!' do
    subject { create(:script) }
    before { allow_any_instance_of(SourceCode).to receive(:sleep).with(60) }

    it 'analyzes source code by type and content and assigns state' do
      subject.reload
      is_expected.to be_safe
    end

    it "assigns site's state if all it's scripts are processed" do
      expect(subject.site.reload).to be_safe
    end

    context "some of site's scripts are not processed" do
      let(:site) { create(:site) }
      let(:script) { create(:script, site: site) }
      before do
        other_script = create(:script, name: 'http://example.com/jquery.min.js', site: site)
        other_script.skip_analyze_source_code = true
        other_script.update_attribute(:state, 'processing')
        site.update_attribute(:state, 'processing')
      end

      it "doesn't assign site's state if any of it's scripts have still processing" do
        expect(script.site).to be_processing
      end
    end

    context 'Session web sockets are present' do
      let(:session) { create(:session) }
      let(:site) { create(:site, session: session) }
      let(:socket) { double('socket') }
      before do
        Sinatra::Application.sockets[session.key] = [socket]
      end

      it 'notifies web sockets that were binded to the current session' do
        expect(socket).to receive(:send).with('URL http://example.com is safe')
        create(:script, site: site)
      end
    end
  end
end
