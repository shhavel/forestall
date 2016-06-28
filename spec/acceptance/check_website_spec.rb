require 'spec_helper'

resource 'Check Website' do
  post '/api/v1/sites' do
    header 'Content-Type', 'application/json'
    parameter :key, 'Unique client key', required: true
    parameter :url, 'Website URL to check for malicious scripts', scope: :site, required: true
    parameter :scripts_attributes, 'Web page source code (with all JS) to make ckeck of', scope: :site, required: true
    parameter :name, 'Script name', scope: :'scripts_attributes[]', required: true
    parameter :type, 'Script type can by one of "html" or "javascript"', scope: :'scripts_attributes[]', required: true
    parameter :content, 'Script content', scope: :'scripts_attributes[]', required: true
    let(:raw_post) { params.to_json }
    let(:session) { Session.create(browser: 'test') }

    example 'Parameter key is required to make check' do
      explanation 'If the server receives a request without a key it will return an error.'
      do_request
      expect(status).to eq(400)
      expect(response_body).to eq('{"message":"Parameter is required","errors":{"key":"Parameter is required"}}')
    end

    example 'Parameter key should match user session to make check' do
      explanation 'If the server receives a request with wrong key it will return an error.'
      do_request(key: '232312', site: { url: 'http://example.com' })
      expect(status).to eq(404)
      expect(response_body).to eq('{"message":"Session not found"}')
    end

    example 'Parameter site is required to make check' do
      explanation 'If provided new site attributes are not present server will return an error.'
      do_request(key: '1234')
      expect(status).to eq(400)
      expect(response_body).to eq('{"message":"Parameter is required","errors":{"site":"Parameter is required"}}')
    end

    example 'Parameter site cannot be blank to make check' do
      explanation 'If provided new site attributes are not present server will return an error.'
      do_request(key: '1234', site: {})
      expect(status).to eq(400)
      expect(response_body).to eq('{"message":"Parameter cannot be blank","errors":{"site":"Parameter cannot be blank"}}')
    end

    example 'Parameter url cannot be blank to make check' do
      explanation 'Checking a website for malicious scripts requires site URL.'
      do_request(key: session.key, site: { url: '' })
      expect(status).to eq(422)
      expect(response_body).to eq(%q({"message":"Url can't be blank","errors":{"url":["can't be blank"]}}))
    end

    example 'Enroll a website for checking on any malicious scripts' do
      explanation 'Send to the server page URL, its content and all JS'
      allow_any_instance_of(SourceCode).to receive(:sleep).with(60)
      do_request(key: session.key, site: {
        url: 'http://example.com',
        scripts_attributes: [
          { name: 'Page Content', type: 'html', content: '<html>content</html>' },
          { name: 'http://example.com/javascripts/jqery.js', type: 'javascript', content: '123' }
        ]
      })
      expect(status).to eq(201)
      expect(parsed_json).to eq({
        type: 'sites',
        id: Site.last._id.to_s,
        attributes: {
          url: 'http://example.com',
          state: 'malicious'
        }
      })
    end
  end

  get '/api/v1/sites/:id' do
    parameter :key, 'Unique client key', required: true
    parameter :id, 'Website ID to check for state ("processing", "safe", "malicious")', required: true
    let(:session) { Session.create(browser: 'test') }
    let(:other_session) { Session.create(browser: 'test') }
    let(:site) { session.sites.create(url: 'http://example.com', state: 'safe') }

    example 'Session key parameter should match site id' do
      explanation 'All enrolled sites are scoped to particular user session. ' \
                  "Server raises error if provided session key doesn't match site id"
      do_request(key: other_session.key, id: site.id)
      expect(status).to eq(404)
      expect(response_body).to eq('{"message":"Site not found"}')
    end

    example 'Check whether it is possible to visit the site or download JS files.' do
      explanation 'Retrieve site checking state. State explanation: "processing" - analyzing is in progress; ' \
                  '"safe" - it is safe to visit the site or download JS files (site doesn’t have malicious scripts); ' \
                  '"malicious" - site visit may harm the user\'s machine (avoid downloading JS files).'
      do_request(key: session.key, id: site.id)
      expect(status).to eq(200)
      expect(parsed_json).to eq({
        type: 'sites',
        id: site._id.to_s,
        attributes: {
          url: 'http://example.com',
          state: 'safe'
        }
      })
    end
  end
end
