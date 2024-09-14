# frozen_string_literal: true

class RebalanceOrderSerializer < ActiveModel::Serializer
  attributes :id, :status, :kind, :amount, :scheduled_at, :created_by_system

  has_one :rebalance
end