# frozen_string_literal: true

require 'hg_brasil/base'

module HgBrasil
  class Quotes < HgBrasil::Base
    def self.quote_details
      new.quote_details
    end

    def quote_details
      get(url: '/quotations')
    end
  end
end
