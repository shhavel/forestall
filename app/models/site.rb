class Site
  include Mongoid::Document
  include StateMachine
  field :url, type: String
  index({ session_id: 1 })
  index({ session_id: 1, url: 1 }, { unique: true })

  belongs_to :session
  has_many :scripts
  accepts_nested_attributes_for :scripts

  validates_presence_of :url
  validates_uniqueness_of :url, scope: :session_id

  def as_json(options = {})
    { type: 'sites',
      id: self._id.to_s,
      attributes: {
        url: self.url,
        state: self.state
      }
    }
  end

  def analyze!
    sleep 60
    self.scripts.each(&:analyze_source_code!)
    assign_state
  end

  def async_analyze!
    if self.scripts.none?(&:processing?)
      assign_state
    else
      SourceCodeAnalyzer.perform_async(self.id.to_s)
    end
  end

  private
    def assign_state
      update_attribute(:state, self.scripts.all?(&:safe?) ? 'safe' : 'malicious')
    end
end
