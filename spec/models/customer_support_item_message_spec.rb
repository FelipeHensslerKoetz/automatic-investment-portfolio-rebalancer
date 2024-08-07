# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerSupportItemMessage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:customer_support_item) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
  end
end
