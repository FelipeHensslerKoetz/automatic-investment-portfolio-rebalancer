# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::RebalanceOrders::AutomaticRebalanceByRecurrenceService do
  let!(:user) { create(:user) }
  let!(:investment_portfolio) { create(:investment_portfolio, user:) }

  describe '.call' do
    subject(:automatic_rebalance_by_recurrence_service_call) { described_class.call(automatic_rebalance_option:) }

    context 'when the automatic rebalance option is valid' do
      context 'when the system needs to create a new rebalance' do
        context 'when generating the first rebalance' do
          let(:automatic_rebalance_option) do
            create(:automatic_rebalance_option, :recurrence, investment_portfolio:, start_date: Time.zone.today)
          end

          it 'create a new rebalance scheduled for the start_date' do
            automatic_rebalance_by_recurrence_service_call

            new_rebalance_order = RebalanceOrder.last

            expect(RebalanceOrder.count).to eq(1)
            expect(new_rebalance_order.investment_portfolio).to eq(investment_portfolio)
            expect(new_rebalance_order.user).to eq(user)
            expect(new_rebalance_order.status).to eq('pending')
            expect(new_rebalance_order.kind).to eq(automatic_rebalance_option.rebalance_order_kind)
            expect(new_rebalance_order.amount).to eq(automatic_rebalance_option.amount)
            expect(new_rebalance_order.error_message).to be_nil
            expect(new_rebalance_order.scheduled_at).to eq(automatic_rebalance_option.start_date)
            expect(new_rebalance_order.created_by_system).to eq(true)
          end
        end

        context 'when generating the next rebalance after the last has been executed' do
          let(:automatic_rebalance_option) do
            create(:automatic_rebalance_option, :recurrence, investment_portfolio:, start_date: Time.zone.today,
            amount: 500.0)
          end

          before do
            create(:rebalance_order, :default, investment_portfolio:, user:, status: 'succeed', scheduled_at: Time.zone.today,
                                     created_by_system: true)
          end

          it 'create a new rebalance scheduled for the next recurrence date' do
            automatic_rebalance_by_recurrence_service_call

            new_rebalance_order = RebalanceOrder.last

            expect(RebalanceOrder.count).to eq(2)
            expect(new_rebalance_order.investment_portfolio).to eq(investment_portfolio)
            expect(new_rebalance_order.user).to eq(user)
            expect(new_rebalance_order.status).to eq('pending')
            expect(new_rebalance_order.kind).to eq(automatic_rebalance_option.rebalance_order_kind)
            expect(new_rebalance_order.amount).to eq(automatic_rebalance_option.amount)
            expect(new_rebalance_order.error_message).to be_nil
            expect(new_rebalance_order.scheduled_at).to eq(
              automatic_rebalance_option.start_date + automatic_rebalance_option.recurrence_days.days
            )
            expect(new_rebalance_order.created_by_system).to eq(true)
          end
        end
      end

      context 'when the system does not need to create a new rebalance' do
        context 'when the last rebalance was not executed yet' do
          let(:automatic_rebalance_option) do
            create(:automatic_rebalance_option, :recurrence, investment_portfolio:, start_date: Time.zone.today)
          end

          before do
            create(:rebalance_order, :default, investment_portfolio:, user:, status: 'pending', scheduled_at: Time.zone.today,
                                     created_by_system: true)
          end

          it 'does not crate a new rebalance order' do
            automatic_rebalance_by_recurrence_service_call

            expect(RebalanceOrder.count).to eq(1)
          end
        end
      end
    end

    context 'when the automatic rebalance option is invalid' do
      context 'when the automatic rebalance option is not a recurrence type' do
        let(:automatic_rebalance_option) do
          create(:automatic_rebalance_option, :variation, investment_portfolio:, start_date: Time.zone.today)
        end

        it 'creates a new error log' do
          automatic_rebalance_by_recurrence_service_call

          expect(Log.error.count).to eq(1)
          expect(Log.error.last.data['message']).to eq('ArgumentError: automatic_rebalance_option is not a recurrence type')
        end
      end

      context 'when the automatic rebalance option is not a rebalance option' do
        let(:automatic_rebalance_option) { nil }

        it 'creates a new error log' do
          automatic_rebalance_by_recurrence_service_call

          expect(Log.error.count).to eq(1)
          expect(Log.error.last.data['message']).to eq('ArgumentError: automatic_rebalance_option is not an automatic rebalance option')
        end
      end
    end
  end
end
