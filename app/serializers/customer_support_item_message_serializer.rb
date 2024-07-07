# frozen_string_literal: true

class CustomerSupportItemMessageSerializer < ActiveModel::Serializer
  attributes :id, :message
  has_one :customer_support_item
  has_one :user
end
