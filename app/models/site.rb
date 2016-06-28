class Site
  include Mongoid::Document
  include StateMachine
  field :url, type: String
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
end
