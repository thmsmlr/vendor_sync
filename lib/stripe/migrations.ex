defmodule VendorSync.Stripe.Migrations do
  use Ecto.Migration

  def up do
    for schema <- VendorSync.Stripe.Schemas.all_schemas() do
      if function_exported?(schema, :up_migration, 0) do
        schema.up_migration()
      end
    end

    create table(:stripe__checkpoint) do
      add(:good_upto_event_id, :string)
      add(:events_processed, :integer, default: 0)
      timestamps()
    end
  end

  def down do
    for schema <- VendorSync.Stripe.Schemas.all_schemas() do
      if function_exported?(schema, :down_migration, 0) do
        schema.down_migration()
      end
    end
  end
end
