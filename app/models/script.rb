class Script
  include Mongoid::Document
  include StateMachine
  field :name, type: String

  before_save :assign_source_code
  after_save :async_analyze_source_code!, unless: :skip_analyze_source_code

  belongs_to :site
  belongs_to :source_code

  validates_presence_of :name
  validates_inclusion_of :type, in: %w(html javascript), unless: :skip_analyze_source_code
  validates_presence_of :content, unless: :skip_analyze_source_code
  attr_accessor :type, :content, :skip_analyze_source_code

  def async_analyze_source_code!
    SourceCodeAnalyzer.perform_async(self.id)
  end

  def analyze_source_code!
    self.source_code.analyze!
    self.skip_analyze_source_code = true
    self.update_attribute(:state, self.source_code.state)
    if self.site.scripts.none?(&:processing?)
      self.site.update_attribute(:state, self.site.scripts.all?(&:safe?) ? 'safe' : 'malicious')
    end
  end

  private
    def assign_source_code
      return unless self.type && self.content
      self.source_code = SourceCode.find_or_create_by(type: self.type, content: self.content)
    end
end
