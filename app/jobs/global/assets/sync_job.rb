# frozen_string_literal: true

module Global
  module Assets
    class SyncJob
      include Sidekiq::Job

      sidekiq_options queue: 'global_assets_sync', retry: false

      def perform
        return if any_rebalance_order_being_processed?

        br_api_assets_sync
        hg_brasil_assets_sync
      end

      private

      def any_rebalance_order_being_processed?
        RebalanceOrder.processing.any?
      end

      def schedule_record(record, delay_in_seconds)
        record.schedule!
        record.update(scheduled_at: Time.zone.now + delay_in_seconds.seconds)
      end

      def asset_ticker_symbols(batch)
        batch.map(&:ticker_symbol).join(',')
      end

      def br_api_assets_sync
        current_delay_in_seconds = 0

        AssetPrice.pending.where(partner_resource: br_api_partner_resource).find_in_batches(batch_size: 20) do |batch|
          batch.each do |batch_item|
            batch_item.with_lock { schedule_record(batch_item, current_delay_in_seconds) }
          end
          BrApi::Assets::SyncJob.perform_in(current_delay_in_seconds.seconds, asset_ticker_symbols(batch))
          current_delay_in_seconds += br_api_schedule_delay_in_seconds
          sleep(1)
        end
      end

      def br_api_partner_resource
        @br_api_partner_resource ||= PartnerResource.find_by!(slug: 'br_api_assets')
      end

      def br_api_schedule_delay_in_seconds
        @br_api_schedule_delay_in_seconds ||= Rails.application.credentials.br_api[:request_delay_in_seconds]
      end

      def hg_brasil_assets_sync
        current_delay_in_seconds = 0

        AssetPrice.pending.where(partner_resource: hg_brasil_partner_resource).find_in_batches(batch_size: 5) do |batch|
          batch.each do |batch_item|
            batch_item.with_lock { schedule_record(batch_item, current_delay_in_seconds) }
          end
          HgBrasil::Assets::SyncJob.perform_in(current_delay_in_seconds.seconds, asset_ticker_symbols(batch))
          current_delay_in_seconds += hg_brasil_schedule_delay_in_seconds
          sleep(1)
        end
      end

      def hg_brasil_partner_resource
        @hg_brasil_partner_resource ||= PartnerResource.find_by!(slug: 'hg_brasil_assets')
      end

      def hg_brasil_schedule_delay_in_seconds
        @hg_brasil_schedule_delay_in_seconds ||= Rails.application.credentials.hg_brasil[:request_delay_in_seconds]
      end
    end
  end
end
