defmodule VendorSync.Stripe.Schemas.PaymentIntent do
  @moduledoc """
  Stripe payment_intent schema.

  Generated from Stripe OpenAPI spec on 2024-07-08
  """

  use Ecto.Schema
  use Ecto.Migration

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "stripe_payment_intent" do
    field(:setup_future_usage, :string)
    field(:payment_method, :string)
    field(:livemode, :boolean)
    field(:processing, :map)
    field(:capture_method, :string)
    field(:payment_method_options, :map)
    field(:amount_received, :integer)
    field(:metadata, :map)
    field(:description, :string)
    field(:payment_method_types, {:array, :string})
    field(:amount_capturable, :integer)
    field(:review, :string)
    field(:confirmation_method, :string)
    field(:next_action, :map)
    field(:on_behalf_of, :string)
    field(:customer, :string)
    field(:amount, :integer)
    field(:invoice, :string)
    field(:automatic_payment_methods, :map)
    field(:statement_descriptor, :string)
    field(:latest_charge, :string)
    field(:application, :string)
    field(:client_secret, :string)
    field(:receipt_email, :string)
    field(:object, :string)
    field(:last_payment_error, :map)
    field(:canceled_at, :integer)
    field(:currency, :string)
    field(:created, :integer)
    field(:cancellation_reason, :string)
    field(:payment_method_configuration_details, :map)
    field(:status, :string)
    field(:transfer_group, :string)
    field(:amount_details, :map)
    field(:application_fee_amount, :integer)
    field(:statement_descriptor_suffix, :string)
    field(:transfer_data, :map)
    field(:shipping, :map)
  end

  def up_migration do
    create table(:stripe_payment_intent, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:setup_future_usage, :string)
      add(:payment_method, :string)
      add(:livemode, :boolean)
      add(:processing, :map)
      add(:capture_method, :string)
      add(:payment_method_options, :map)
      add(:amount_received, :integer)
      add(:metadata, :map)
      add(:description, :string)
      add(:payment_method_types, {:array, :string})
      add(:amount_capturable, :integer)
      add(:review, :string)
      add(:confirmation_method, :string)
      add(:next_action, :map)
      add(:on_behalf_of, :string)
      add(:customer, :string)
      add(:amount, :integer)
      add(:invoice, :string)
      add(:automatic_payment_methods, :map)
      add(:statement_descriptor, :string)
      add(:latest_charge, :string)
      add(:application, :string)
      add(:client_secret, :string)
      add(:receipt_email, :string)
      add(:object, :string)
      add(:last_payment_error, :map)
      add(:canceled_at, :integer)
      add(:currency, :string)
      add(:created, :integer)
      add(:cancellation_reason, :string)
      add(:payment_method_configuration_details, :map)
      add(:status, :string)
      add(:transfer_group, :string)
      add(:amount_details, :map)
      add(:application_fee_amount, :integer)
      add(:statement_descriptor_suffix, :string)
      add(:transfer_data, :map)
      add(:shipping, :map)
    end
  end

  def down_migration do
    drop(table(:stripe_payment_intent))
  end

  def api_route, do: "/v1/payment_intents"
  def object_type, do: "payment_intent"
end