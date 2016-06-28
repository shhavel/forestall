class SourceCodeAnalyzer
  include Sidekiq::Worker

  sidekiq_options queue: :analyze_source_code, retry: 5

  def perform(script_id)
    $logger.info "#<Script _id: #{script_id}> processing..."
    script = Script.find(script_id)
    script.analyze_source_code!

    if !script.site.reload.processing? && (sockets = Sinatra::Application.sockets[script.site.session.key]).present?
      msg = "URL #{script.site.url} is #{script.site.state}"
      sockets.each { |s| s.send(msg) }
    end
  end
end
