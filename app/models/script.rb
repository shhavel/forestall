class Script
  include Mongoid::Document
  include StateMachine
  field :name, type: String
  index({ site_id: 1 })

  before_save :assign_source_code

  belongs_to :site
  belongs_to :source_code

  validates_presence_of :name
  validates_inclusion_of :type, in: %w(html javascript), unless: :source_code
  validates_presence_of :content, unless: :source_code
  attr_accessor :type, :content

  def analyze_source_code!
    self.source_code.analyze!
    self.update_attribute(:state, self.source_code.state)
  end

  private
    def assign_source_code
      return unless self.type && self.content
      self.source_code = SourceCode.find_or_create_by(type: self.type, content: self.content)
      self.state = self.source_code.state
    end
end
