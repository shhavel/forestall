class SourceCode
  include Mongoid::Document
  include StateMachine
  field :type, type: String
  field :content, type: String
  index({ type: 1, content: 1 }, { unique: true })

  has_many :scripts

  validates_inclusion_of :type, in: %w(html javascript)
  validates_presence_of :content
  validates_uniqueness_of :content, scope: :type

  def analyze!
    return true unless processing?
    processed_state = (self.content.size % 2 == 0) ? 'safe' : 'malicious'
    update_attribute(:state, processed_state)
  end
end
