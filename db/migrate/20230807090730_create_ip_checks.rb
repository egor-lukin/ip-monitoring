# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :ip_checks do
      primary_key :id
      foreign_key :ip_address_id, :ip_addresses

      column :rtt, Integer, null: true
      column :dropped, TrueClass, null: false

      column :started_at, DateTime, null: false
    end
  end
end
