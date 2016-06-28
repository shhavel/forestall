class SourceCodeAnalyzer
  include Sidekiq::Worker

  sidekiq_options queue: :analyze_source_code, retry: 5

  def perform(site_id)
    $logger.info "#<Site _id: #{site_id}> processing..."
    site = Site.find(site_id)
    site.analyze!

    if (sockets = Sinatra::Application.sockets[site.session.key]).present?
      msg = "URL #{site.url} is #{site.state}"
      sockets.each { |s| s.send(msg) }
    end
  end
end
