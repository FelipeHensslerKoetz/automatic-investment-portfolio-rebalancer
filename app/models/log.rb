# frozen_string_literal: true

class Log < ApplicationRecord
  # Constants
  LOG_KINDS = %i[error info].freeze

  # Validations
  validates :kind, :data, presence: true
  validates :kind, inclusion: { in: LOG_KINDS.map(&:to_s) }
end
