# frozen_string_literal: true

class Log < ApplicationRecord
  # Constants
  LOG_KINDS = %i[error info].freeze

  # Scopes
  scope :error, -> { where(kind: :error) }
  scope :info, -> { where(kind: :info) }

  # Validations
  validates :kind, :data, presence: true
  validates :kind, inclusion: { in: LOG_KINDS.map(&:to_s) }
end
