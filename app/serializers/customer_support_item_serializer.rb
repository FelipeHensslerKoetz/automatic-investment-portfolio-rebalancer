# frozen_string_literal: true

class CustomerSupportItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status
end
