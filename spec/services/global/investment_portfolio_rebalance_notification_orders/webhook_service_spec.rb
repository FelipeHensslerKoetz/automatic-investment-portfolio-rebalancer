# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Global::InvestmentPortfolioRebalanceNotificationOrders::WebhookService do
  describe '.call' do
    subject(:webhook_request) { described_class.call(params) }

    context 'when http_method is post' do
      context 'when request succeed' do
        let(:params) do
          {
            url: 'https://webhook.site/f9c7614e-dfde-4845-9519-1458c5692570',
            http_method: 'post',
            header: { 'Content-Type': 'application/json' },
            body: { key: 'value' }.to_json
          }
        end

        it 'calls Faraday.post' do
          VCR.use_cassette('webhook_service/post_success') do
            response = webhook_request

            expect(response).to eq(
              {
                success: true,
                response: 'This URL has no default content configured. <a href="https://webhook.site/#!/view/f9c7614e-dfde-4845-9519-1458c5692570">View in Webhook.site</a>.'
              }
            )
          end
        end
      end

      context 'when request fails' do
        let(:params) do
          {
            url: 'https://webhook/site/f9c7614e-dfde-4845-9519-1458c5692570',
            http_method: 'post',
            header: { 'Content-Type': 'application/json' },
            body: { key: 'value' }.to_json
          }
        end

        before do
          allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::TimeoutError)
        end

        it 'calls Faraday.post' do
          response = webhook_request

          expect(response).to eq(
            {
              success: false,
              response: 'timeout'
            }
          )
        end
      end
    end

    context 'when params are invalid' do
      let(:params) do
        {
          url: 'a',
          http_method: 'a',
          header: 'a',
          body: 'a'
        }
      end

      it 'raises an error' do
        response = webhook_request

        expect(response).to eq(
          {
            success: false,
            response: 'Invalid Params: {:url=>"a", :http_method=>"a", :header=>"a", :body=>"a"}'
          }
        )
      end
    end
  end
end
