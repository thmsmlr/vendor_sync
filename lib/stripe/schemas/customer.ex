defmodule VendorSync.Stripe.Schemas.Customer do
  @moduledoc """
  Stripe customer schema.

  Generated from Stripe OpenAPI spec on 2024-07-08
  """

  use Ecto.Schema
  use Ecto.Migration

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "stripe_customer" do
    field(:address, :map)
    field(:balance, :integer)
    field(:cash_balance, :map)
    field(:created, :integer)
    field(:currency, :string)
    field(:default_source, :string)
    field(:delinquent, :boolean)
    field(:description, :string)
    field(:discount, :map)
    field(:email, :string)
    field(:invoice_credit_balance, :map)
    field(:invoice_prefix, :string)
    field(:invoice_settings, :map)
    field(:livemode, :boolean)
    field(:metadata, :map)
    field(:name, :string)
    field(:next_invoice_sequence, :integer)
    field(:object, :string)
    field(:phone, :string)
    field(:preferred_locales, {:array, :string})
    field(:shipping, :map)
    field(:sources, :map)
    field(:subscriptions, :map)
    field(:tax, :map)
    field(:tax_exempt, :string)
    field(:tax_ids, :map)
    field(:test_clock, :string)
  end

  def up_migration do
    create table(:stripe_customer, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:address, :map)
      add(:balance, :integer)
      add(:cash_balance, :map)
      add(:created, :integer)
      add(:currency, :string)
      add(:default_source, :string)
      add(:delinquent, :boolean)
      add(:description, :string)
      add(:discount, :map)
      add(:email, :string)
      add(:invoice_credit_balance, :map)
      add(:invoice_prefix, :string)
      add(:invoice_settings, :map)
      add(:livemode, :boolean)
      add(:metadata, :map)
      add(:name, :string)
      add(:next_invoice_sequence, :integer)
      add(:object, :string)
      add(:phone, :string)
      add(:preferred_locales, {:array, :string})
      add(:shipping, :map)
      add(:sources, :map)
      add(:subscriptions, :map)
      add(:tax, :map)
      add(:tax_exempt, :string)
      add(:tax_ids, :map)
      add(:test_clock, :string)
    end
  end

  def down_migration do
    drop(table(:stripe_customer))
  end

  def api_route, do: "/v1/customers"
  def object_type, do: "customer"
end