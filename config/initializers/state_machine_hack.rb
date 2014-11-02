# Rails 4.1.0.rc1 and StateMachine don't play nice

require 'state_machine/version'

unless StateMachine::VERSION == '1.2.0'
  # If you see this message, please test removing this file
  # If it's still required, please bump up the version above
  Rails.logger.warn "Please remove me, StateMachine version has changed"
end

module StateMachine::Integrations::ActiveModel
  alias_method :around_validation_protected, :around_validation
  def around_validation(*args, &block)
    around_validation_protected(*args, &block)
  end
end