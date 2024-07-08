defmodule VendorSync.Stripe.Schemas.Charge do
  @moduledoc """
  Stripe charge schema.

  Generated from Stripe OpenAPI spec on 2024-07-08
  """

  use Ecto.Schema
  use Ecto.Migration

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "stripe_charge" do
    field(:receipt_url, :string)
    field(:payment_method, :string)
    field(:livemode, :boolean)
    field(:calculated_statement_descriptor, :string)
    field(:radar_options, :map)
    field(:metadata, :map)
    field(:description, :string)
    field(:paid, :boolean)
    field(:application_fee, :string)
    field(:failure_message, :string)
    field(:review, :string)
    field(:payment_intent, :string)
    field(:refunds, :map)
    field(:on_behalf_of, :string)
    field(:customer, :string)
    field(:fraud_details, :map)
    field(:amount, :integer)
    field(:outcome, :map)
    field(:invoice, :string)
    field(:payment_method_details, :map)
    field(:statement_descriptor, :string)
    field(:balance_transaction, :string)
    field(:application, :string)
    field(:receipt_email, :string)
    field(:failure_balance_transaction, :string)
    field(:receipt_number, :string)
    field(:failure_code, :string)
    field(:object, :string)
    field(:amount_captured, :integer)
    field(:billing_details, :map)
    field(:captured, :boolean)
    field(:amount_refunded, :integer)
    field(:refunded, :boolean)
    field(:currency, :string)
    field(:created, :integer)
    field(:transfer, :string)
    field(:source_transfer, :string)
    field(:status, :string)
    field(:transfer_group, :string)
    field(:disputed, :boolean)
    field(:application_fee_amount, :integer)
    field(:statement_descriptor_suffix, :string)
    field(:transfer_data, :map)
    field(:shipping, :map)
  end

  def up_migration do
    create table(:stripe_charge, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:receipt_url, :string)
      add(:payment_method, :string)
      add(:livemode, :boolean)
      add(:calculated_statement_descriptor, :string)
      add(:radar_options, :map)
      add(:metadata, :map)
      add(:description, :string)
      add(:paid, :boolean)
      add(:application_fee, :string)
      add(:failure_message, :string)
      add(:review, :string)
      add(:payment_intent, :string)
      add(:refunds, :map)
      add(:on_behalf_of, :string)
      add(:customer, :string)
      add(:fraud_details, :map)
      add(:amount, :integer)
      add(:outcome, :map)
      add(:invoice, :string)
      add(:payment_method_details, :map)
      add(:statement_descriptor, :string)
      add(:balance_transaction, :string)
      add(:application, :string)
      add(:receipt_email, :string)
      add(:failure_balance_transaction, :string)
      add(:receipt_number, :string)
      add(:failure_code, :string)
      add(:object, :string)
      add(:amount_captured, :integer)
      add(:billing_details, :map)
      add(:captured, :boolean)
      add(:amount_refunded, :integer)
      add(:refunded, :boolean)
      add(:currency, :string)
      add(:created, :integer)
      add(:transfer, :string)
      add(:source_transfer, :string)
      add(:status, :string)
      add(:transfer_group, :string)
      add(:disputed, :boolean)
      add(:application_fee_amount, :integer)
      add(:statement_descriptor_suffix, :string)
      add(:transfer_data, :map)
      add(:shipping, :map)
    end
  end

  def down_migration do
    drop(table(:stripe_charge))
  end

  def api_route, do: "/v1/charges"
  def object_type, do: "charge"
end