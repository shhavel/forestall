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

  describe '#analyze!' do
    context 'Session web sockets are present' do
      let(:session) { create(:session, safe_sites_count: 10, malicious_sites_count: 1) }
      let(:site) { create(:site, session: session) }
      let(:socket) { double('socket') }
      before do
        create(:script, site: site, content: '1234')
        create(:script, site: site, content: '1234')
        allow_any_instance_of(Site).to receive(:sleep).with(60)
        Sinatra::Application.sockets[session.key] = [socket]
      end

      it "assigns site's state to 'safe' if all of sorce codes are safe" do
        site.analyze!
        expect(site.state).to eq('safe')
      end

      it "increments session safe_sites_count if all of sorce codes are safe" do
        site.analyze!
        expect(session.reload.safe_sites_count).to eq(11)
      end

      it "assigns site's state to 'malicious' if at least one of sorce_code is malicious" do
        create(:script, site: site, content: '123')
        site.analyze!
        expect(site.state).to eq('malicious')
      end

      it "increments session malicious_sites_count if at least one of sorce_code is malicious" do
        create(:script, site: site, content: '123')
        site.analyze!
        expect(session.reload.malicious_sites_count).to eq(2)
      end
    end
  end

  describe '#async_analyze!' do
    context 'Session web sockets are present' do
      let(:session) { create(:session) }
      let(:site) { create(:site, session: session) }
      let!(:script) { create(:script, site: site) }
      let(:socket) { double('socket') }
      before do
        allow_any_instance_of(Site).to receive(:sleep).with(60)
        Sinatra::Application.sockets[session.key] = [socket]
      end

      it 'notifies web sockets that were binded to the current session' do
        expect(socket).to receive(:send).with('URL http://example.com is safe')
        site.async_analyze!
      end
    end
  end
end
