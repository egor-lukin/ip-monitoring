# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :ip_addresses do
      primary_key :id

      column :value, 'inet', null: false
      column :reachable, TrueClass
      column :monitoring_enabled, TrueClass, null: false

      column :created_at, DateTime, null: false
      column :deleted_at, DateTime

      index :value, unique: true, where: { deleted_at: nil }
    end
  end
end
