require 'rails_helper'

RSpec.describe Global::RebalanceOrders::AutomaticRebalanceByVariationService do
  describe '.call' do
    subject(:automatic_rebalance_by_variation_service) do
      described_class.call(automatic_rebalance_option:)
    end

    let(:user) { create(:user) }
    let!(:brl_currency) { create(:currency, :brl) }
    let!(:usd_currency) { create(:currency, :usd) }
    let!(:investment_portfolio) { create(:investment_portfolio, user:) }

    context 'when the automatic rebalance option is variation' do
      context 'when the variation of any asset is greater than the variation percentage' do
        let(:automatic_rebalance_option) do
          create(:automatic_rebalance_option, :variation, investment_portfolio:,
                                                          amount: 50.0)
        end

        before do
          asset = create(:asset, ticker_symbol: 'IVVB11')
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset:, currency: usd_currency, status: :updated, price: 40.0)
          create(:investment_portfolio_asset, investment_portfolio:, asset:, target_allocation_weight_percentage: 50, quantity: 10,
                                              target_variation_limit_percentage: 17)

          second_asset = create(:asset, ticker_symbol: 'BOVA11')
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :updated,
                                                                        price: 100.0)
          create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 50,
                                              quantity: 10, target_variation_limit_percentage: 17)

          brl_usd_currency_parity = create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency)
          create(:currency_parity_exchange_rate, :with_hg_brasil_currencies_partner_resource, currency_parity: brl_usd_currency_parity,
                                                                                              exchange_rate: 5.0,
                                                                                              status: :updated)
        end

        context 'when no previous order has been created today' do
          it 'should create a rebalance order for this day' do
            automatic_rebalance_by_variation_service

            expect(RebalanceOrder.count).to eq(1)

            new_rebalance_order = RebalanceOrder.first

            expect(new_rebalance_order.investment_portfolio).to eq(investment_portfolio)
            expect(new_rebalance_order.user).to eq(investment_portfolio.user)
            expect(new_rebalance_order.status).to eq('pending')
            expect(new_rebalance_order.kind).to eq(automatic_rebalance_option.rebalance_order_kind)
            expect(new_rebalance_order.amount).to eq(automatic_rebalance_option.amount)
            expect(new_rebalance_order.scheduled_at).to eq(Time.zone.today)
            expect(new_rebalance_order.created_by_system).to eq(true)
          end
        end

        context 'when a previous order has been created today' do
          before do
            create(:rebalance_order, investment_portfolio:, user:, status: 'pending', kind: automatic_rebalance_option.rebalance_order_kind,
                                     amount: automatic_rebalance_option.amount, scheduled_at: Time.zone.today, created_by_system: true)
          end

          it 'should not create another rebalance order for this day' do
            automatic_rebalance_by_variation_service

            expect(RebalanceOrder.count).to eq(1)
            expect(Log.error.count).to eq(0)
          end
        end
      end

      context 'when the variation is inside the acceptable range' do
        let(:automatic_rebalance_option) { create(:automatic_rebalance_option, :variation, investment_portfolio:) }

        before do
          asset = create(:asset, ticker_symbol: 'IVVB11')
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset:, currency: usd_currency, status: :updated, price: 40.0)
          create(:investment_portfolio_asset, investment_portfolio:, asset:, target_allocation_weight_percentage: 50, quantity: 10,
                                              target_variation_limit_percentage: 17)

          second_asset = create(:asset, ticker_symbol: 'BOVA11')
          create(:asset_price, :with_hg_brasil_assets_partner_resource, asset: second_asset, currency: brl_currency, status: :updated,
                                                                        price: 100.0)
          create(:investment_portfolio_asset, investment_portfolio:, asset: second_asset, target_allocation_weight_percentage: 50,
                                              quantity: 10, target_variation_limit_percentage: 17)

          brl_usd_currency_parity = create(:currency_parity, currency_from: usd_currency, currency_to: brl_currency)
          create(:currency_parity_exchange_rate, :with_hg_brasil_currencies_partner_resource, currency_parity: brl_usd_currency_parity,
                                                                                              exchange_rate: 5.0,
                                                                                              status: :updated)
        end

        it 'should not create another rebalance order for this day' do
          automatic_rebalance_by_variation_service

          expect(RebalanceOrder.count).to eq(0)
          expect(Log.error.count).to eq(0)
        end
      end
    end

    context 'when the automatic rebalance option is not variation' do
      let(:automatic_rebalance_option) { create(:automatic_rebalance_option, :average_price) }

      it 'should not create a rebalance order' do
        automatic_rebalance_by_variation_service

        expect(RebalanceOrder.count).to eq(0)
        expect(Log.error.count).to eq(1)
        expect(Log.error.first.data['context']).to eq("Global::RebalanceOrders::AutomaticRebalanceByVariationService - automatic_rebalance_option=#{automatic_rebalance_option&.id}")
        expect(Log.error.first.data['message']).to eq('ArgumentError: automatic_rebalance_option does not have variation kind')
      end
    end
  end
end
