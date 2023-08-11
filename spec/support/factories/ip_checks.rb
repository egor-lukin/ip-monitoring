# frozen_string_literal: true

Factory.define(:ip_check) do |f|
  f.rtt 100
  f.dropped false
  f.started_at DateTime.new(2023, 1, 1)

  f.trait :dropped do |t|
    t.dropped true
    t.rtt nil
  end

  f.association(:ip_address)
end
