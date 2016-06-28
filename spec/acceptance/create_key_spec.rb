require 'spec_helper'

resource 'Client Key' do
  post '/api/v1/sessions' do
    header 'Content-Type', 'application/json'
    parameter :browser, 'Browser name - the only one of client metrics', scope: :session, required: true
    let(:raw_post) { params.to_json }

    example 'Parameter session is required in order to get the key' do
      explanation 'If the server receives a request without parameter session (associative array) it will return an error.'
      do_request
      expect(status).to eq(400)
      expect(response_body).to eq('{"message":"Parameter is required","errors":{"session":"Parameter is required"}}')
    end

    example 'Parameter session cannot be blank' do
      explanation 'If provided new session attributes are not present server will return an error.'
      do_request(session: {})
      expect(status).to eq(400)
      expect(response_body).to eq('{"message":"Parameter cannot be blank","errors":{"session":"Parameter cannot be blank"}}')
    end

    example 'Parameter session[browser] cannot be blank' do
      explanation 'If the server receives a request without parameter session[browser] it will return an error.'
      do_request(session: { browser: '' })
      expect(status).to eq(422)
      expect(response_body).to eq(%q({"message":"Browser can't be blank","errors":{"browser":["can't be blank"]}}))
    end

    example 'Request a unique key that passed to the server with all further requests' do
      explanation 'The client sends a request to the server for a unique key passing client metrics ' \
        '(for now only browser name). This key is passed to the server with all further requests. ' \
        'If the server receives a request without this key it will return an error.'
      do_request(session: { browser: 'test' })
      expect(status).to eq(201)
      expect(parsed_json).to eq({
        type: 'sessions',
        id: Session.last.key,
        attributes: {
          safe_sites_count: 0,
          malicious_sites_count: 0
        }
      })
    end
  end
end
