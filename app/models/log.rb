class Log < ApplicationRecord
  # Constants
  LOG_TYPES = %i[error http_request info].freeze

  # Validations
  validates :type, :data, presence: true
  validates :type, inclusion: { in: LOG_TYPES.map(&:to_s) }
end
