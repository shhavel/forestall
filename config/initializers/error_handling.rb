error(404) do
  [404, { 'Content-Type' => 'application/json' }, ['{"message":"Not found"}']]
end
error(Mongoid::Errors::DocumentNotFound) do
  [404, { 'Content-Type' => 'application/json' },
    { message: "#{env['sinatra.error'].klass} not found" }.to_json]
end
error(Mongoid::Errors::Validations) do
  [422, { 'Content-Type' => 'application/json' },
    { message: env['sinatra.error'].record.errors.full_messages.join("\n"),
      errors: env['sinatra.error'].record.errors.messages }.to_json]
end
error { '{"message":"An internal server error occurred. Please try again later."}' }
