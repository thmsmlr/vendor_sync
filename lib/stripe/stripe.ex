defmodule VendorSync.Stripe do
  @moduledoc """

  Sync Stripe data into your database using Ecto and a Genserver.

  First, let's configure vendor_sync,

  ```
  config :vendor_sync,
    repo: MyApp.Repo,
    stripe: [
      secret_key: System.get_env("STRIPE_SECRET_KEY") || raise("STRIPE_SECRET_KEY is not set")
    ]
  ```

  This will configure the repo and secret key that the Stripe API will use and the tables that the data will be synced to.

  Then you'll need to create an Ecto Migration to create the tables for the stripe data.

  ```bash
  mix ecto.gen.migration add_vendor_sync_stripe_tables
  ```

  Then, go edit the migration file to add the up and down migrations for the stripe data.

  ```
  defmodule MyApp.Repo.Migrations.AddVendorSyncStripeTables do
    use Ecto.Migration

    def up do
      VendorSync.Stripe.Migration.up()
    end

    def down do
      VendorSync.Stripe.Migration.down()
    end
  end
  ```

  Then, run `mix ecto.migrate` to apply the migrations.

  ```bash
  mix ecto.migrate
  ```

  Now we need to run the backfill to get the initial data into the database.

  ```
  iex -S mix
  iex> VendorSync.Stripe.backfill()
  ```

  Once complete, you'll want to setup the `VendorSync.Stripe.EventsPoller` to sync new data as it comes in.
  Don't worry, the events poller will catch any data changes that happen in between the backfill job and doing this
  next step so long as you start running the events poller within 7 days of the initial backfill.

  Let's add the `VendorSync.Stripe.EventsPoller` to our application's supervision tree.

  ```
  # lib/my_app/application.ex
  def application do
    [
      MyApp.Repo,
      VendorSync.Stripe.EventsPoller,
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
  ```

  Then, when you start the application, the `VendorSync.Stripe.EventsPoller` will start polling for new data.
  """

  def backfill do
    VendorSync.Stripe.Backfill.run()
  end
end
