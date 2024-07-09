# VendorSync

> _Ever wonder how many support tickets submitted by users acquired from a specific ad campaign?_ <br/>
> _What's your NPS score, by email campaign?_ <br/>
> _What's the refund rate of users who use a specific feature in your app?_ <br/>
> _Are your sales people notified when their lead submits a support ticket?_ <br/>
> _Can you email sales leads who tried your app in the last 7 days and didn't convert?_ 

These are all valuable questions, but answering them requires data from multiple sources.
Some need internal application data, while others rely on information from CRMs, payment providers, email services, or spreadsheets.
Answering these questions or building automations around them is challenging because the data is scattered across different systems rather than consolidated in a single database.

VendorSync is a ETL tool for Elixir that synchronizes data from various SaaS vendors into your database. 
The synchronization process typically involves a backfill job and a GenServer that continuously updates with the latest changes, though this may vary by vendor.
For detailed information on specific SaaS vendors, please refer to [the documentation](#).

## Supported SaaS Vendors

- [x] Stripe ([Setup Guide](./lib/stripe/stripe.ex))
- [ ] Google Sheets
- [ ] Hubspot
- [ ] Salesforce
- [ ] Zendesk
- [ ] Freshdesk
- [ ] Facebook Ad Manager
- [ ] Amazon SES

## Installation

```elixir
def deps do
  [
    {:vendor_sync, github: "thmsmlr/vendor_sync"}
  ]
end
```

## Companies using this in production

***Your company could be here, create an issue, please let me know!***


### Maybe?

- [ ] Do we need to Expand objects?
- [ ] Paginate children as well? what are examples

### TODO

- [ ] Configurable table prefix
- [ ] Create migrations for Stripe objects
  - [x] Customer
  - [x] Charge
  - [ ] Invoice
  - [ ] InvoiceItem
  - [ ] Payment
  - [ ] PaymentMethod
  - [x] PaymentIntent
  - [ ] Refund
  - [ ] Subscription

