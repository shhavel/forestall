class SourceCodeAnalyzer
  include Sidekiq::Worker

  sidekiq_options queue: :analyze_source_code, retry: 5

  def perform(script_id)
    script = Script.find(script_id)
    script.analyze_source_code!
  end
end
