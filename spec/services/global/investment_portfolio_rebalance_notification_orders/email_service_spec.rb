require 'rails_helper'

RSpec.describe Global::InvestmentPortfolioRebalanceNotificationOrders::EmailService do
  describe '.call' do
    subject(:email_service_call) { described_class.call(email: email, rebalance: rebalance) }

    let(:rebalance) { create(:rebalance) }
    let(:email) { 'myemail@gmail.com' }

    context 'when email was sent successfully' do
      it 'returns success' do
        response = email_service_call
        expect(response).to eq({ success: true })
        expect(ActionMailer::Base.deliveries.count ).to eq(1)
      end
    end

    context 'when email was not sent' do
      before do
        allow(UserMailer).to receive(:rebalance_notification_email).and_raise(StandardError, 'StandardError')
      end

      it 'returns error' do
        response = email_service_call
        expect(response).to eq({ success: false, response: 'StandardError' })
        expect(ActionMailer::Base.deliveries.count ).to eq(0)
      end
    end
  end
end