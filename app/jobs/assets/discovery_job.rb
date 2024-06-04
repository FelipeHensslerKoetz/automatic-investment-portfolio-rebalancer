# frozen_string_literal: true

module Assets
  class DiscoveryJob
    include Sidekiq::Job

    sidekiq_options queue: 'asset_discovery', retry: false

    def perform(keywords)
      Assets::Discovery::GlobalService.new(keywords:).call
    end
  end
end