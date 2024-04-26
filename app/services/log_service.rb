# frozen_string_literal: true

class LogService
  attr_reader :kind, :data

  def self.create_log(kind:, data:)
    new(kind:, data:).create_log
  end

  def initialize(kind:, data:)
    @kind = kind
    @data = data
  end

  def create_log
    return unless valid_log_kind? && valid_data?

    Log.create!(kind:, data:)
  end

  private

  def valid_log_kind?
    Log::LOG_KINDS.include?(kind.to_sym)
  end

  def valid_data?
    data.is_a?(Hash) || data.is_a?(Array)
  end
end
