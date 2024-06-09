# frozen_string_literal: true

class Rebalance < ApplicationRecord
  # Modules
  include AASM

  # Associations
  belongs_to :rebalance_order

  # Validations
  validates :before_state, :after_state, :details, :recommended_actions, presence: true
end
