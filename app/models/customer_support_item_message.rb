# frozen_string_literal: true

class CustomerSupportItemMessage < ApplicationRecord
  # Associations
  belongs_to :customer_support_item
  belongs_to :user

  # Validations
  validates :message, presence: true
end
