# frozen_string_literal: true

require 'rails_helper'

RSpec.describe System::Logs::CreatorService do
  subject(:log_service) { described_class.create_log(kind:, data:) }

  describe '.create_log' do
    context 'when arguments are valid' do
      let(:kind) { :info }
      let(:data) { { message: 'This is a log!' } }

      it 'creates a log' do
        expect { log_service }.to change(Log, :count).by(1)
      end
    end

    context 'when arguments are invalid' do
      context 'when kind is not mapped' do
        let(:kind) { 'invalid_kind' }
        let(:data) { { key: 'value' } }

        it 'does not create a log' do
          expect { log_service }.not_to change(Log, :count)
        end
      end

      context 'when data is not a hash or array' do
        let(:kind) { :kind }
        let(:data) { 'invalid_data' }

        it 'does not create a log' do
          expect { log_service }.not_to change(Log, :count)
        end
      end
    end
  end
end
