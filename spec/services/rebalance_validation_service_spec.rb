# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RebalanceValidationService do
  subject(:rebalance_validation_service) { described_class.new(rebalance_order_id:) }

  describe 'when the rebalance order is valid' do
    let(:brl_currency) { create(:currency, :brl) }
    let(:rebalance_order_id) { rebalance_order.id }
    let(:rebalance_order) { create(:rebalance_order, status: :scheduled, investment_portfolio:) }
    let(:investment_portfolio) { create(:investment_portfolio, currency: brl_currency) }

    before do
      first_asset = create(:asset)
      create(:asset_price, :with_hg_brasil_stock_price_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
      create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, allocation_weight: 50)

      second_asset = create(:asset)
      create(:asset_price, :with_hg_brasil_stock_price_partner_resource, asset: second_asset, currency: brl_currency, status: :updated)
      create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, allocation_weight: 50)
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

      it { expect { rebalance_validation_service.call }.to raise_error(RebalanceOrderInvalidStatusError) }
    end

    context 'when the investment portfolio assets count is invalid' do
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, :scheduled) }

      it { expect { rebalance_validation_service.call }.to raise_error(InvestmentPortfolioInvalidAssetsCountError) }
    end

    context 'when the investment portfolio total allocation weight is invalid' do
      let(:brl_currency) { create(:currency, :brl) }
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, status: :scheduled, investment_portfolio:) }
      let(:investment_portfolio) { create(:investment_portfolio, currency: brl_currency) }

      before do
        first_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_stock_price_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
        create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, allocation_weight: 50)

        second_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_stock_price_partner_resource, asset: second_asset, currency: brl_currency, status: :updated)
        create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, allocation_weight: 45)
      end

      it { expect { rebalance_validation_service.call }.to raise_error(InvestmentPortfolioInvalidTotalAllocationWeightError) }
    end

    context 'when any of the the investment portfolio assets prices are not up to date' do
      let(:brl_currency) { create(:currency, :brl) }
      let(:rebalance_order_id) { rebalance_order.id }
      let(:rebalance_order) { create(:rebalance_order, status: :scheduled, investment_portfolio:) }
      let(:investment_portfolio) { create(:investment_portfolio, currency: brl_currency) }

      before do
        first_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_stock_price_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
        create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, allocation_weight: 50)

        second_asset = create(:asset)
        create(:asset_price, :with_hg_brasil_stock_price_partner_resource, asset: second_asset, currency: brl_currency, status: :scheduled)
        create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, allocation_weight: 50)
      end

      it { expect { rebalance_validation_service.call }.to raise_error(AssetOutdatedError) }
    end
  end
end
