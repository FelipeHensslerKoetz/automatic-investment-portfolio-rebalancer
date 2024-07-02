# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::InvestmentPortfolioAssets::CreatorService do
  subject(:creator_service) do
    described_class.call(investment_portfolio:, investment_portfolio_assets_attributes:)
  end

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  context 'when the investment portfolio belongs to the user' do
    let(:investment_portfolio) { create(:investment_portfolio, user:) }

    context 'when params are valid' do
      context 'when creating the investment portfolio assets' do
        let(:asset) { create(:asset) }
        let(:another_asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            {
              'asset_id' => asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 50.0,
              'target_variation_limit_percentage' => 10.0
            },
            {
              'asset_id' => another_asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 50.0,
              'target_variation_limit_percentage' => 10.0
            }
          ]
        end

        it 'creates the investment portfolio assets' do
          creator_service

          investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.find_by(asset:)
          another_investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.find_by(asset: another_asset)

          expect(investment_portfolio_asset).to be_present
          expect(investment_portfolio_asset.quantity).to eq(10.0)
          expect(investment_portfolio_asset.target_allocation_weight_percentage).to eq(50.0)
          expect(investment_portfolio_asset.target_variation_limit_percentage).to eq(10.0)

          expect(another_investment_portfolio_asset).to be_present
          expect(another_investment_portfolio_asset.quantity).to eq(10.0)
          expect(another_investment_portfolio_asset.target_allocation_weight_percentage).to eq(50.0)
          expect(another_investment_portfolio_asset.target_variation_limit_percentage).to eq(10.0)
        end
      end

      context 'when adding an asset to the investment portfolio' do
        let(:asset) { create(:asset) }
        let(:another_asset) { create(:asset) }
        let(:new_asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            {
              'asset_id' => asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 33.0,
              'target_variation_limit_percentage' => 10.0
            },
            {
              'asset_id' => another_asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 33.0,
              'target_variation_limit_percentage' => 10.0
            },
            {
              'asset_id' => new_asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 34.0,
              'target_variation_limit_percentage' => 10.0
            }
          ]
        end

        before do
          create(:investment_portfolio_asset, investment_portfolio:, asset:, 'target_allocation_weight_percentage' => 50.0)
          create(:investment_portfolio_asset, investment_portfolio:, asset: another_asset, 'target_allocation_weight_percentage' => 50.0)
        end

        it 'adds the new asset to the investment portfolio' do
          creator_service

          investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.find_by(asset:)
          another_investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.find_by(asset: another_asset)
          new_investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.find_by(asset: new_asset)

          expect(investment_portfolio_asset).to be_present
          expect(investment_portfolio_asset.quantity).to eq(10.0)
          expect(investment_portfolio_asset.target_allocation_weight_percentage).to eq(33.0)
          expect(investment_portfolio_asset.target_variation_limit_percentage).to eq(10.0)

          expect(another_investment_portfolio_asset).to be_present
          expect(another_investment_portfolio_asset.quantity).to eq(10.0)
          expect(another_investment_portfolio_asset.target_allocation_weight_percentage).to eq(33.0)
          expect(another_investment_portfolio_asset.target_variation_limit_percentage).to eq(10.0)

          expect(new_investment_portfolio_asset).to be_present
          expect(new_investment_portfolio_asset.quantity).to eq(10.0)
          expect(new_investment_portfolio_asset.target_allocation_weight_percentage).to eq(34.0)
          expect(new_investment_portfolio_asset.target_variation_limit_percentage).to eq(10.0)
        end
      end

      context 'when removing an asset from the investment portfolio' do
        let(:asset) { create(:asset) }
        let(:another_asset) { create(:asset) }
        let(:new_asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            {
              'asset_id' => asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 100.0,
              'target_variation_limit_percentage' => 10.0
            },
            {
              '_destroy' => true,
              'asset_id' => another_asset.id
            }
          ]
        end

        before do
          create(:investment_portfolio_asset, investment_portfolio:, asset:, 'target_allocation_weight_percentage' => 50.0)
          create(:investment_portfolio_asset, investment_portfolio:, asset: another_asset, 'target_allocation_weight_percentage' => 50.0)
        end

        it 'adds the new asset to the investment portfolio' do
          creator_service

          investment_portfolio_asset = investment_portfolio.investment_portfolio_assets.find_by(asset:)

          expect(investment_portfolio_asset).to be_present
          expect(investment_portfolio_asset.quantity).to eq(10.0)
          expect(investment_portfolio_asset.target_allocation_weight_percentage).to eq(100.0)
          expect(investment_portfolio_asset.target_variation_limit_percentage).to eq(10.0)
        end
      end
    end

    context 'when params are invalid' do
      context 'when asset cannot be found' do
        context 'when asset id is invalid' do
          let(:investment_portfolio_assets_attributes) do
            [
              'asset_id' => nil,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 100.0,
              'target_variation_limit_percentage' => 10.0
            ]
          end

          it 'raises an ActiveRecord::RecordNotFound error' do
            expect { creator_service }.to raise_error(ActiveRecord::RecordNotFound, 'Asset not found')
          end
        end

        context 'when a user asset does not belong to the current user' do
          let(:asset) { create(:asset, user: another_user, custom: true) }

          let(:investment_portfolio_assets_attributes) do
            [
              'asset_id' => asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 100.0,
              'target_variation_limit_percentage' => 10.0
            ]
          end

          it 'raises an ActiveRecord::RecordNotFound error' do
            expect { creator_service }.to raise_error(ActiveRecord::RecordNotFound, 'Asset not found')
          end
        end
      end

      context 'when there is a rebalance order being processed' do
        let(:asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            'asset_id' => asset.id,
            'quantity' => 10.0,
            'target_allocation_weight_percentage' => 100.0,
            'target_variation_limit_percentage' => 10.0
          ]
        end

        before do
          create(:rebalance_order, investment_portfolio:, status: 'processing')
        end

        it 'raises an InvestmentPortfolios::RebalanceOrderInProgressError error' do
          expect { creator_service }.to raise_error(InvestmentPortfolios::RebalanceOrderInProgressError)
        end
      end

      context 'when the investment portfolio total weight is invalid' do
        let(:asset) { create(:asset) }
        let(:another_asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            {
              'asset_id' => asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 50.0,
              'target_variation_limit_percentage' => 10.0
            },
            {
              'asset_id' => another_asset.id,
              'quantity' => 10.0,
              'target_allocation_weight_percentage' => 49.0,
              'target_variation_limit_percentage' => 10.0
            }
          ]
        end

        it 'raises an InvestmentPortfolios::InvalidTotalAllocationWeightError error' do
          expect { creator_service }.to raise_error(InvestmentPortfolios::InvalidTotalAllocationWeightError)
        end
      end

      context 'when the investment_portfolio_asset allocation weight is invalid' do
        let(:investment_portfolio_assets_attributes) do
          [
            'asset_id' => asset.id,
            'quantity' => 10.0,
            'target_allocation_weight_percentage' => -100.0,
            'target_variation_limit_percentage' => 10.0
          ]
        end
      end

      context 'when target deviation percentage is invalid' do
        let(:asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            'asset_id' => asset.id,
            'quantity' => 10.0,
            'target_allocation_weight_percentage' => 100.0,
            'target_variation_limit_percentage' => -1.0
          ]
        end

        it 'raises an ActiveRecord::RecordNotFound error' do
          expect { creator_service }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when quantity is invalid' do
        let(:asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            'asset_id' => asset.id,
            'quantity' => -10.0,
            'target_allocation_weight_percentage' => 100.0,
            'target_variation_limit_percentage' => 10.0
          ]
        end

        it 'raises an ActiveRecord::RecordNotFound error' do
          expect { creator_service }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when target_allocation_weight percentage is invalid' do
        let(:asset) { create(:asset) }

        let(:investment_portfolio_assets_attributes) do
          [
            'asset_id' => asset.id,
            'quantity' => 10.0,
            'target_allocation_weight_percentage' => -1,
            'target_variation_limit_percentage' => 10.0
          ]
        end

        it 'raises an ActiveRecord::RecordNotFound error' do
          expect { creator_service }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
