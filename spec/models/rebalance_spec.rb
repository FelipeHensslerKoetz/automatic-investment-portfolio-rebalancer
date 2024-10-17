# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rebalance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:rebalance_order) }
    it { is_expected.to have_many(:investment_portfolio_rebalance_notification_orders).dependent(:destroy) }
  end
end
