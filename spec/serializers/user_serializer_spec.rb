# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  describe 'attributes' do
    it 'returns the correct attributes' do
      user = build(:user)
      serializer = described_class.new(user)

      expect(serializer.attributes).to eq(
        id: user.id,
        name: user.name,
        email: user.email
      )
    end
  end
end
