# VendorSync

_Ever wonder how many support tickets submitted by users acquired from a specific ad campaign?_ <br/>
_What's your NPS score, by email campaign?_ <br/>
_What's the refund rate of users who use a specific feature in your app?_ <br/>
_Are your sales people notified when their lead submits a support ticket?_ <br/>
_Can you email sales leads who tried your app in the last 7 days and didn't convert?_ 

These are all great questions to ask, but they require data from disparate sources.
Some require internal app data, others require data from a CRM, payment provider, email service, or even a spreadsheet.
You can't answer these questions, let alone build automations around them because the data isn't in a single database.

VendorSync is a reverse ETL tool for Elixir that lets you sync data in various SaaS vendors into your database. 
It varies by vendor, but there is typically a backfill job and a Genserver that continusouly sync's the latest changes.
For details on a specific SaaS vendor, check out [the documentation.](#).

## Supported SaaS Vendors

- [x] Stripe ([Setup Guide](./lib/stripe/schemas.ex))
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

