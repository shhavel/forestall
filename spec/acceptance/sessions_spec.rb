require 'spec_helper'

resource 'Track User Session' do
  get '/api/v1/sessions/:key' do
    parameter :key, 'User session unique key', required: true
    let(:session) { Session.create(browser: 'test', safe_sites_count: 1412, malicious_sites_count: 2) }

    example 'Track session statistics' do
      explanation 'Server tracks all URLs visited by a particular user. ' \
                  'Users can see a number of safe and not safe sites that they visited.'
      do_request(key: session.key)
      expect(status).to eq(200)
      expect(parsed_json).to eq({
        type: 'sessions',
        id: session.key,
        attributes: {
          safe_sites_count: 1412,
          malicious_sites_count: 2
        }
      })
    end

    example 'Server returns an error if session key is wrong' do
      explanation 'Server returns an error if cannot find session with provided key'
      do_request(key: '0987654321')
      expect(status).to eq(404)
      expect(response_body).to eq('{"message":"Session not found"}')
    end
  end

  get '/api/v1/sessions' do
    example_request 'Server returns an error if session key is missed' do
      explanation 'Parameter key is required to track session.'
      expect(status).to eq(404)
      expect(response_body).to eq('{"message":"Not found"}')
    end
  end
end
