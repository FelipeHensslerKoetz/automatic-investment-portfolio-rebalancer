require 'rails_helper'

RSpec.describe Global::InvestmentPortfolioRebalanceNotificationOrders::NotificationService, type: :service do
  describe '.call' do
    subject(:notification_service) do
      described_class.call(investment_portfolio_rebalance_notification_order:)
    end

    context 'when the notification has webhook kind' do
      context 'when notification is successful' do
        context 'when investment_portfolio_rebalance_notification_order is pending' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_webhook_investment_portfolio_rebalance_notification_option,
                   status: :pending)
          end

          let(:webhook_params) do
            {
              url: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.url,
              header: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.header,
              body: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.body.to_json
            }
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              url: 'https://webhook.site/f9c7614e-dfde-4845-9519-1458c5692570',
              body: { 'key' => 'value' },
              header: { 'Content-Type' => 'application/json' }
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService).to receive(:call).with(
              webhook_params
            ).and_call_original
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to success and saves the API response' do
            VCR.use_cassette('webhook_flux_call_success') do
              notification_service
              expect(Log.error.count).to eq(0)
              expect(investment_portfolio_rebalance_notification_order).to be_success
              expect(Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService).to have_received(:call).with(
                webhook_params
              ).once
            end
          end
        end

        context 'when investment_portfolio_rebalance_notification_order is error' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_webhook_investment_portfolio_rebalance_notification_option,
                   status: :error)
          end

          let(:webhook_params) do
            {
              url: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.url,
              header: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.header,
              body: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.body.to_json
            }
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              url: 'https://webhook.site/f9c7614e-dfde-4845-9519-1458c5692570',
              body: { 'key' => 'value' },
              header: { 'Content-Type' => 'application/json' }
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService).to receive(:call).with(
              webhook_params
            ).and_call_original
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to success and saves the API response' do
            VCR.use_cassette('webhook_flux_call_success') do
              notification_service
              expect(Log.error.count).to eq(0)
              expect(investment_portfolio_rebalance_notification_order).to be_success
              expect(Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService).to have_received(:call).with(
                webhook_params
              ).once
            end
          end
        end
      end

      context 'when notification failed' do
        context 'when investment_portfolio_rebalance_notification_order is pending' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_webhook_investment_portfolio_rebalance_notification_option,
                   status: :pending)
          end

          let(:webhook_params) do
            {
              url: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.url,
              header: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.header,
              body: investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.body.to_json
            }
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              url: 'https://webhook/site/f9c7614e-dfde-4845-9519-1458c5692570',
              body: { 'key' => 'value' },
              header: { 'Content-Type' => 'application/json' }
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService).to receive(:call).with(
              webhook_params
            ).and_call_original

            allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::TimeoutError)
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to error and saves the error message' do
            notification_service
            expect(investment_portfolio_rebalance_notification_order).to be_error
            expect(investment_portfolio_rebalance_notification_order.error_message).to eq('timeout')
            expect(Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService).to have_received(:call).with(
              webhook_params
            ).once
          end
        end

        context 'when investment_portfolio_rebalance_notification_order is error' do
        end
      end
    end

    context 'when the notification has email kind' do
      context 'when notification is successful' do
        context 'when investment_portfolio_rebalance_notification_order status is pending' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_email_investment_portfolio_rebalance_notification_option,
                   status: :pending)
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              email: 'myemail@gmail.com'
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to receive(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).and_call_original
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to success' do
            notification_service
            expect(Log.error.count).to eq(0)
            expect(investment_portfolio_rebalance_notification_order).to be_success
            expect(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to have_received(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).once
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end

        context 'when investment_portfolio_rebalance_notification_order status is error' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_email_investment_portfolio_rebalance_notification_option,
                   status: :error)
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              email: 'myemail@gmail.com'
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to receive(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).and_call_original
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to success' do
            notification_service
            expect(Log.error.count).to eq(0)
            expect(investment_portfolio_rebalance_notification_order).to be_success
            expect(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to have_received(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).once
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      context 'when notification failed' do
        context 'when investment_portfolio_rebalance_notification_order is pending' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_email_investment_portfolio_rebalance_notification_option,
                   status: :pending)
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              email: 'myemail@gmail.com'
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to receive(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).and_call_original
            allow(UserMailer).to receive_message_chain(:rebalance_notification_email, :deliver_now).and_raise(StandardError, 'StandardError')
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to error' do
            notification_service
            expect(Log.error.count).to eq(0)
            expect(investment_portfolio_rebalance_notification_order).to be_error
            expect(investment_portfolio_rebalance_notification_order.error_message).to eq('StandardError')
            expect(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to have_received(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).once
            expect(ActionMailer::Base.deliveries.count).to eq(0)
          end
        end

        context 'when investment_portfolio_rebalance_notification_order is error' do
          let(:investment_portfolio_rebalance_notification_order) do
            create(:investment_portfolio_rebalance_notification_order, :with_email_investment_portfolio_rebalance_notification_option,
                   status: :error)
          end

          before do
            investment_portfolio_rebalance_notification_order.investment_portfolio_rebalance_notification_option.update!(
              email: 'myemail@gmail.com'
            )

            allow(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to receive(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).and_call_original
            allow(UserMailer).to receive_message_chain(:rebalance_notification_email, :deliver_now).and_raise(StandardError, 'StandardError')
          end

          it 'updates the investment_portfolio_rebalance_notification_order status to error' do
            notification_service
            expect(Log.error.count).to eq(0)
            expect(investment_portfolio_rebalance_notification_order).to be_error
            expect(investment_portfolio_rebalance_notification_order.error_message).to eq('StandardError')
            expect(Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService).to have_received(:call).with(
              { email: 'myemail@gmail.com', rebalance: investment_portfolio_rebalance_notification_order.rebalance }
            ).once
            expect(ActionMailer::Base.deliveries.count).to eq(0)
          end
        end
      end
    end

    context 'when an exception is raised' do
      context 'when investment_portfolio_rebalance_notification_order is not a investment_portfolio_rebalance_notification_order' do
        let(:investment_portfolio_rebalance_notification_order) { nil }

        before do
          notification_service
        end

        it 'creates an error log' do
          error_log = Log.error.first
          expect(Log.error.count).to eq(1)
          expect(error_log['data']['message']).to eq('ArgumentError: Invalid investment_portfolio_rebalance_notification_order')
        end
      end

      context 'when investment_portfolio_rebalance_notification_order may not process or reprocess' do
        let(:investment_portfolio_rebalance_notification_order) do
          create(:investment_portfolio_rebalance_notification_order, :with_webhook_investment_portfolio_rebalance_notification_option,
                 status: :processing)
        end

        before do
          notification_service
        end

        it 'creates an error log' do
          error_log = Log.error.first
          expect(Log.error.count).to eq(1)
          expect(error_log['data']['message']).to eq('StandardError: Invalid investment_portfolio_rebalance_notification_order status')
        end
      end
    end
  end
end
