# frozen_string_literal: true

Factory.define(:ip_monitoring_period) do |f|
  f.started_at DateTime.new(2023, 12, 1)
  f.ended_at DateTime.new(2023, 12, 2)

  f.trait :active do |t|
    t.ended_at nil
  end

  f.association(:ip_address)
end
