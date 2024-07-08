# frozen_string_literal: true

module Integrations
  module HgBrasil
    class Currencies < Integrations::HgBrasil::Base
      def self.quote_details
        new.quote_details
      end

      def quote_details
        get(url: '/quotations')
      end
    end
  end
end
