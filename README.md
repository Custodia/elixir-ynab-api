# YnabApi

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ynab_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ynab_api, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ynab_api](https://hexdocs.pm/ynab_api).

## YNAB api v1 coverage

### User
- [x] User info (**GET** user)

### Budgets
- [x] List budgets (**GET** budgets)
- [ ] Single budget (**GET** budgets/{budget_id})
- [x] Budget Settings (**GET** budgets/{budget_id}/settings)

### Accounts

The accounts for a budget

- [x] Account list (**GET** budgets/{budget_id}/accounts)
- [x] Single account (**GET** budgets/{budget_id}/accounts/{account_id})

### Categories

The categories for a budget

- [x] List categories (**GET** budgets/{budget_id}/categories)
- [x] Single category (**GET** budgets/{budget_id}/categories/{category_id})
- [ ] Single category for a specific budget month (**GET** budgets/{budget_id}/months/{month}/categories/{category_id})
- [ ] Update an existing month category (**PATCH** budgets/{budget_id}/months/{month}/categories/{category_id})

### Payees

The payees for a budget

- [x] List payees (**GET** budgets/{budget_id}/payees)
- [x] Single payee (**GET** budgets/{budget_id}/payees/{payee_id})

### Payee Locations

When you enter a transaction and specify a payee on the YNAB mobile apps, the GPS coordinates for that location are stored, with your permission, so that the next time you are in the same place (like the Grocery store) we can pre-populate nearby payees for you! It’s handy and saves you time. This resource makes these locations available. Locations will not be available for all payees.

- [ ] List payee locations (**GET** budgets/{budget_id}/payee_locations)
- [ ] Single payee location (**GET** budgets/{budget_id}/payee_locations/{payee_location_id})
- [ ] List locations for a payee (**GET** budgets/{budget_id}/payees/{payee_id}/payee_locations)

### Months

Each budget contains one or more months, which is where To be Budgeted, Age of Money and category (budgeted / activity / balances) amounts are available.

- [ ] List budget months (**GET** budgets/{budget_id}/months)
- [ ] Single budget month (**GET** budgets/{budget_id}/months/{month})

### Transactions

The transactions for a budget

- [ ] List transactions (**GET** budgets/{budget_id}/transactions)
- [ ] Create a single transaction or multiple transactions (**POST** budgets/{budget_id}/transactions)
- [ ] Bulk create transactions (**POST** budgets/{budget_id}/transactions/bulk)
- [ ] List account transactions (**GET** budgets/{budget_id}/accounts/{account_id}/transactions)
- [ ] List category transactions (**GET** budgets/{budget_id}/categories/{category_id}/transactions)
- [ ] List payee transactions (**GET** budgets/{budget_id}/payees/{payee_id}/transactions)
- [ ] Single transaction (**GET** budgets/{budget_id}/transactions/{transaction_id})
- [ ] Updates an existing transaction (**PUT** budgets/{budget_id}/transactions/{transaction_id})

### Scheduled Transactions

The scheduled transactions for a budget

- [ ] List scheduled transactions (**GET** budgets/{budget_id}/scheduled_transactions)
- [ ] Single scheduled transaction (**GET** budgets/{budget_id}/scheduled_transactions/{scheduled_transaction_id})
