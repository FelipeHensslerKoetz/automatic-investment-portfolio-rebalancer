# frozen_string_literal: true

module Assets
  module Global
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'assets_global_sync', retry: false

      def perform
        return if any_rebalance_order_being_processed?

        hg_brasil_sync
      end

      private

      def hg_brasil_partner_resource
        @hg_brasil_partner_resource ||= PartnerResource.find_by(slug: :hg_brasil_stock_price)
      end

      def any_rebalance_order_being_processed?
        RebalanceOrder.processing.any?
      end

      def hg_brasil_sync
        current_delay_in_seconds = 0

        AssetPrice.updated.where(partner_resource: hg_brasil_partner_resource).find_in_batches(batch_size: 5) do |batch|
          batch.each { |batch_item| schedule_record(batch_item, current_delay_in_seconds) }
          Assets::HgBrasil::SyncJob.perform_in(current_delay_in_seconds.seconds, asset_ticker_symbols(batch))
          current_delay_in_seconds += hg_brasil_schedule_delay_in_seconds
        end
      end

      def schedule_record(record, delay_in_seconds)
        record.update(scheduled_at: Time.zone.now + delay_in_seconds.seconds)
        record.schedule!
      end

      def asset_ticker_symbols(batch)
        batch.map(&:ticker_symbol).join(',')
      end

      def hg_brasil_schedule_delay_in_seconds
        @hg_brasil_schedule_delay_in_seconds ||= Rails.application.credentials.hg_brasil[:request_delay_in_seconds]
      end
    end
  end
end
