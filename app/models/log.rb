class Log < ApplicationRecord
  # Constants
  LOG_KINDS = %i[error http_request info].freeze

  # Validations
  validates :kind, :data, presence: true
  validates :kind, inclusion: { in: LOG_KINDS.map(&:to_s) }
end
