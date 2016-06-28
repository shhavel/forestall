class Session
  include Mongoid::Document
  field :browser, type: String
  field :safe_sites_count, type: Integer, default: 0
  field :malicious_sites_count, type: Integer, default: 0

  has_many :sites

  validates_presence_of :browser

  def key
    self._id.to_s
  end

  def as_json(options = {})
    { type: 'sessions',
      id: self.key,
      attributes: {
        safe_sites_count: self.safe_sites_count,
        malicious_sites_count: self.malicious_sites_count
      }
    }
  end
end
