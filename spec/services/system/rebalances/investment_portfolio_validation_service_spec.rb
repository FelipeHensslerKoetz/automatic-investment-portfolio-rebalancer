require 'rails_helper'

RSpec.describe System::Rebalances::InvestmentPortfolioValidationService do
  describe '.call' do
    subject(:investment_portfolio_validation_service) { described_class.call(investment_portfolio:) }

    context 'when investment portfolio is valid' do
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

      it { expect { investment_portfolio_validation_service }.not_to raise_error }
    end

    context 'when investment portfolio is invalid' do
      context 'when investment portfolio does not exist' do
        let(:investment_portfolio) { nil }

        it { expect { investment_portfolio_validation_service }.to raise_error(NoMethodError) }
      end

      context 'when investment portfolio has invalid assets count' do
        let(:investment_portfolio) { create(:investment_portfolio) }

        it { expect { investment_portfolio_validation_service }.to raise_error(InvestmentPortfolios::InvalidAssetsCountError) }
      end

      context 'when investment portfolio has invalid total allocation weight' do
        let(:investment_portfolio) { create(:investment_portfolio) }

        before do
          first_asset = create(:asset)
          create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, target_allocation_weight_percentage: 50)

          second_asset = create(:asset)
          create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 45)
        end

        it { expect { investment_portfolio_validation_service }.to raise_error(InvestmentPortfolios::InvalidTotalAllocationWeightError) }
      end

      context 'when investment portfolio has invalid asset prices' do
        let(:brl_currency) { create(:currency, :brl) }
        let(:investment_portfolio) { create(:investment_portfolio) }

        before do
          first_asset = create(:asset)
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: first_asset, currency: brl_currency, status: :updated)
          create(:investment_portfolio_asset, investment_portfolio:, asset: first_asset, target_allocation_weight_percentage: 50)

          second_asset = create(:asset)
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :scheduled)
          create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 50)
        end

        it { expect { investment_portfolio_validation_service }.to raise_error(Assets::OutdatedError) }
      end

      # TODO
      context 'when the investment portfolio has average_price kind and any investment_portfolio_asset.average_price is nil' do 
        
      end

      # TODO
      context 'when the investment_portfolio has variation automatic rebalance option and any investment_portfolio_asset.variation is nil' do
    
      end
    end
  end
end
