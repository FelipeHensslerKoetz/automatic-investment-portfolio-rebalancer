# frozen_string_literal: true

class CurrencySerializer < ActiveModel::Serializer
  attributes :id, :name, :code
end
