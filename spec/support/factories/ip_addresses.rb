# frozen_string_literal: true

Factory.define(:ip_address) do |f|
  f.value '8.8.8.8'
  f.monitoring_enabled true
  f.created_at { fake(:date, :in_date_period) }

  f.trait :without_monitoring do |t|
    t.monitoring_enabled false
  end

  f.trait :deleted do |t|
    t.deleted_at { fake(:date, :in_date_period) }
  end
end
