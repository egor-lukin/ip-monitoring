# frozen_string_literal: true

module Relations
  class IpChecks < ROM::Relation[:sql]
    schema(:ip_checks, infer: true) do
      associations do
        belongs_to :ip_address
      end
    end

    def statistics(time_from, time_to, id)
      with_enabled_monitoring
        .with_specific_address(id)
        .with_specific_time(time_from, time_to)
        .select_stats
        .unordered
        .one
    end

    def with_enabled_monitoring
      join(:ip_monitoring_periods, ip_address_id: :ip_address_id)
        .where(ip_monitoring_periods[:started_at] <= ip_checks[:started_at])
        .where do
        (ip_monitoring_periods[:ended_at] =~ nil) | (ip_monitoring_periods[:ended_at] >= ip_checks[:started_at])
      end
    end

    def with_specific_address(id)
      where(ip_checks[:ip_address_id] => id)
    end

    def with_specific_time(time_from, time_to)
      where { (started_at >= time_from) & (started_at <= time_to) }
    end

    # TODO: simplify method
    # rubocop:disable Metrics/AbcSize
    def select_stats
      select do
        [
          integer.cast(integer.avg(rtt), :integer).as(:avg_rtt),
          integer.min(rtt).as(:min_rtt),
          integer.max(rtt).as(:max_rtt),
          integer.cast(float.percentile_cont(0.5).within_group(rtt), :integer).as(:median_rtt),
          float.round(integer.stddev(rtt), 2).as(:stddev_rtt),
          (integer.count(id).filter(dropped.is(true)) * 100 / integer.nullif(integer.count(id), 0)).as(:dropped)
        ]
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
