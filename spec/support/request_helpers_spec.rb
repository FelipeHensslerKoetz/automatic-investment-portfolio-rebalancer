# frozen_string_literal: true

require 'rails_helper'
require 'support/request_helpers'

class DummyClass
  include Request::JsonHelpers

  attr_reader :response
end

RSpec.describe Request::JsonHelpers do
  let(:dummy_class) { DummyClass.new }

  describe '#json_response' do
    before do
      allow(dummy_class).to receive(:response).and_return(response)
    end

    context 'when JSON is present' do
      let(:response) { double('response', body: '{"foo":"bar"}') }

      it 'parses JSON response' do
        expect(dummy_class.json_response).to eq(foo: 'bar')
      end
    end
  end
end
