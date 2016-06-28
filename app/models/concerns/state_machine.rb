module StateMachine
  def self.included(base)
    base.class_eval do
      field :state, type: String, default: 'processing'
    end
  end

  def processing?
    self.state == 'processing'
  end

  def safe?
    self.state == 'safe'
  end
end
