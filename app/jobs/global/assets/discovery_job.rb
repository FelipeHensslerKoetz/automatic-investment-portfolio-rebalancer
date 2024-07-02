# frozen_string_literal: true

module Global
  module Assets
    class DiscoveryJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_assets_discovery', retry: false

      def perform(keywords)
        Global::Assets::DiscoveryService.new(keywords:).call
      end
    end
  end
end
