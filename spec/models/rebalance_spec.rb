# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rebalance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:rebalance_order) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:before_state) }
    it { is_expected.to validate_presence_of(:after_state) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:recommended_actions) }
  end
end
