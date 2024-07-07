# frozen_string_literal: true

class CustomerSupportItem < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :user
  has_many :messages, class_name: 'CustomerSupportItemMessage', dependent: :restrict_with_error

  # Validations
  validates :title, :description, :status, presence: true

  # AASM
  aasm column: :status do
    state :opened, initial: true
    state :in_progress
    state :closed

    event :progress do
      transitions from: :opened, to: :in_progress
    end

    event :close do
      transitions from: :in_progress, to: :closed
    end
  end
end
