defmodule YnabApi do
  @moduledoc """
  # YnabApi

  This module contains elixir mappings for all YNAB (You Need a Budget) REST api v1 endpoints.
  """

  alias YnabApi.WorkerSupervisor
  alias YnabApi.Models

  @type budget_id :: binary() | :last_used
  @type return_value(result_type) :: {:ok, result_type} | {:error, any()}

  @doc """
  Gets user information from YNAB api.

  See YnabApi.Models.User for what data is available.
  """
  @spec get_user(binary()) :: {:ok, %Models.User{}} | {:error, any()}
  def get_user(access_token), do:
    call_worker(access_token, :get_user)

  @doc """
  Gets a list of the users budget summaries from the YNAB api.

  See YnabApi.Models.BudgetSummary for what data is available.
  """
  @spec get_budgets(binary()) :: return_value(list(%Models.BudgetSummary{}))
  def get_budgets(access_token), do:
    call_worker(access_token, :get_budgets)

  @doc """
  Gets the settings for a given budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.BudgetSettings for what data is available.
  """
  @spec get_budget_settings(binary(), budget_id()) :: return_value(%Models.BudgetSettings{})
  def get_budget_settings(access_token, :last_used), do:
    get_budget_settings(access_token, "last-used")
  def get_budget_settings(access_token, budget_id), do:
    call_worker(access_token, {:get_budget_settings, budget_id})

  @doc """
  Gets the accounts for a given budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.Account for what data is available.
  """
  @spec get_accounts(binary(), budget_id()) :: return_value(list(%Models.Account{}))
  def get_accounts(access_token, :last_used), do:
    get_accounts(access_token, "last-used")
  def get_accounts(access_token, budget_id), do:
    call_worker(access_token, {:get_accounts, budget_id})

  @doc """
  Gets account for given account id in budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.Account for what data is available.
  """
  @spec get_account(binary(), budget_id(), binary()) :: return_value(%Models.Account{})
  def get_account(access_token, :last_used, account_id), do:
    get_account(access_token, "last-used", account_id)
  def get_account(access_token, budget_id, account_id), do:
    call_worker(access_token, {:get_account, budget_id, account_id})

  @doc """
  Gets the category groups and categories for a given budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.CategoryGroup for what data is available.
  """
  @spec get_categories(binary(), budget_id()) :: return_value(list(%Models.CategoryGroup{}))
  def get_categories(access_token, :last_used), do:
    get_categories(access_token, "last-used")
  def get_categories(access_token, budget_id), do:
    call_worker(access_token, {:get_categories, budget_id})

  @doc """
  Gets category for given category id in budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.Category for what data is available.
  """
  @spec get_category(binary(), budget_id(), binary()) :: return_value(%Models.CategoryGroup{})
  def get_category(access_token, :last_used, category_id), do:
    get_category(access_token, "last-used", category_id)
  def get_category(access_token, budget_id, category_id), do:
    call_worker(access_token, {:get_category, budget_id, category_id})

  @doc """
  Gets the payees for a given budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.Payee for what data is available.
  """
  @spec get_payees(binary(), budget_id()) :: return_value(list(%Models.Payee{}))
  def get_payees(access_token, :last_used), do:
    get_payees(access_token, "last-used")
  def get_payees(access_token, budget_id), do:
    call_worker(access_token, {:get_payees, budget_id})

  @doc """
  Gets payee for given payee id in budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.Payee for what data is available.
  """
  @spec get_payee(binary(), budget_id(), binary()) :: return_value(%Models.Payee{})
  def get_payee(access_token, :last_used, payee_id), do:
    get_payee(access_token, "last-used", payee_id)
  def get_payee(access_token, budget_id, payee_id), do:
    call_worker(access_token, {:get_payee, budget_id, payee_id})

  # Helpers

  @spec call_worker(binary(), YnabApi.Worker.request) :: {:ok, struct()} | {:ok, list(struct())} | {:error, any()}
  defp call_worker(access_token, request) do
    case WorkerSupervisor.get_or_start_child(access_token) do
      {:ok, pid} ->
        case GenServer.call(pid, request) do
          result = {:ok, _result} ->
            result
          error_tuple = {:error, _error} ->
            error_tuple
        end
      error_tuple -> error_tuple
    end
  end
end
