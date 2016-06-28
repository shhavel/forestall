module RequestsHelper
  # Parsed response_body.
  def parsed_json
    JSON.parse(response_body, symbolize_names: true)
  end
end

RSpec.configure do |config|
  config.include RequestsHelper
end
