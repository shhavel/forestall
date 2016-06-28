require_relative 'config/environment'

post '/api/v1/sessions' do
  param :session, Hash, required: true, blank: false
  status 201
  Session.create!(params[:session]).to_json
end

get '/api/v1/sessions/:key' do
  param :key, String, required: true, blank: false
  Session.find(params[:key]).to_json
end

post '/api/v1/sites' do
  param :key, String, required: true, blank: false
  param :site, Hash, required: true, blank: false
  session = Session.find(params[:key])
  status 201
  site = session.sites.create!(params[:site])
  site.to_json
end

get '/api/v1/sites/:id' do
  param :key, String, required: true, blank: false
  param :id, String, required: true, blank: false
  session = Session.find(params[:key])
  site = session.sites.find(params[:id])
  site.to_json
end
