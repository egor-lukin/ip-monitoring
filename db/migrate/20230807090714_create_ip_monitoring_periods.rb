# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :ip_monitoring_periods do
      primary_key :id
      foreign_key :ip_address_id, :ip_addresses, unique: true

      column :started_at, DateTime, null: false
      column :ended_at, DateTime, null: true
    end
  end
end
