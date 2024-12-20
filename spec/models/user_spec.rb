# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:assets).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:investment_portfolios).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:rebalance_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:customer_support_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:customer_support_item_messages).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:automatic_rebalance_options).through(:investment_portfolios) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end
end
