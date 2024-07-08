# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::Rebalances::ValidationService do
  subject(:rebalance_validation_service) { described_class.new(rebalance_order_id:) }

  describe 'when the rebalance order is valid' do
    let(:brl_currency) { create(:currency, :brl) }
    let(:rebalance_order_id) { rebalance_order.id }
    let(:rebalance_order) { create(:rebalance_order, status: :scheduled, investment_portfolio:) }
    let(:investment_portfolio) { create(:investment_portfolio) }

    before do
      first_asset = create(:asset)
      create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
      create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, target_allocation_weight_percentage: 50)

      second_asset = create(:asset)
      create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :updated)
      create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 50)
    end

    it { expect(rebalance_validation_service.call).to be_truthy }
  end

  describe 'when the rebalance order is invalid' do
    context 'when the rebalance order is not found' do
      let(:rebalance_order_id) { nil }

      it { expect { rebalance_validation_service.call }.to raise_error(ArgumentError, 'RebalanceOrder not found, id=') }
    end

    context 'when the rebalance order status is different from scheduled' do
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, status: :processing) }

      it { expect { rebalance_validation_service.call }.to raise_error(RebalanceOrders::InvalidStatusError) }
    end

    context 'when the investment portfolio assets count is invalid' do
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, :scheduled) }

      it { expect { rebalance_validation_service.call }.to raise_error(InvestmentPortfolios::InvalidAssetsCountError) }
    end

    context 'when the investment portfolio total allocation weight is invalid' do
      let(:brl_currency) { create(:currency, :brl) }
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, status: :scheduled, investment_portfolio:) }
      let(:investment_portfolio) { create(:investment_portfolio) }

      before do
        first_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
        create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, target_allocation_weight_percentage: 50)

        second_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :updated)
        create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 45)
      end

      it { expect { rebalance_validation_service.call }.to raise_error(InvestmentPortfolios::InvalidTotalAllocationWeightError) }
    end

    context 'when any of the the investment portfolio assets prices are not up to date' do
      let(:brl_currency) { create(:currency, :brl) }
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, status: :scheduled, investment_portfolio:) }
      let(:investment_portfolio) { create(:investment_portfolio) }

      before do
        first_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
        create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, target_allocation_weight_percentage: 50)

        second_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :scheduled)
        create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 50)
      end

      it { expect { rebalance_validation_service.call }.to raise_error(Assets::OutdatedError) }
    end
  end
end
