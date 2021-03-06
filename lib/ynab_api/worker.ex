defmodule YnabApi.Worker do
  use GenServer, restart: :transient

  require Logger
  alias YnabApi.Models

  @base_url "https://api.youneedabudget.com/v1"
  @timeout 900000 # 15 minutes

  @type request :: :get_user | :get_budgets | {:get_budget_settings, binary()} | {:get_accounts, binary()} | {:get_account, binary(), binary()} | {:get_categories, binary()} | {:get_category, binary(), binary()} | {:get_payees, binary()} | {:get_payee, binary(), binary()} | {:get_payee_locations, binary()} | {:get_payee_locations, binary(), binary()} | {:get_payee_location, binary(), binary()} | {:get_all_transactions, binary()} | {:get_account_transactions, binary(), binary()} | {:get_category_transactions, binary(), binary()} | {:get_payee_transactions, binary(), binary()} | {:get_transaction, binary(), binary()} | {:get_scheduled_transactions, binary()} | {:get_scheduled_transaction, binary(), binary()}

  def start_link(access_token) do
    name = get_name(access_token)
    GenServer.start_link(__MODULE__, access_token, name: name)
  end

  # Callbacks

  @impl GenServer
  def init(access_token) do
    {:ok, access_token, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, access_token) do
    url = "#{@base_url}/user"

    case request_and_parse(access_token, url, Models.User) do
      {:ok, %Models.User{}} ->
        {:noreply, access_token, @timeout}
      {:error, error} ->
        {:stop, {:shutdown, error}, access_token}
    end
  end

  @impl GenServer
  def handle_call(:get_user, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/user", Models.User)
  def handle_call(:get_budgets, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets", Models.BudgetSummary)
  def handle_call({:get_budget_settings, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/settings", Models.BudgetSettings)
  def handle_call({:get_accounts, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/accounts", Models.Account)
  def handle_call({:get_account, budget_id, account_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/accounts/#{account_id}", Models.Account)
  def handle_call({:get_categories, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/categories", Models.CategoryGroup)
  def handle_call({:get_category, budget_id, category_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/categories/#{category_id}", Models.Category)
  def handle_call({:get_payees, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/payees", Models.Payee)
  def handle_call({:get_payee, budget_id, payee_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/payees/#{payee_id}", Models.Payee)
  def handle_call({:get_payee_locations, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/payee_locations", Models.PayeeLocation)
  def handle_call({:get_payee_locations, budget_id, payee_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/payees/#{payee_id}/payee_locations", Models.PayeeLocation)
  def handle_call({:get_payee_location, budget_id, payee_location_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/payee_locations/#{payee_location_id}", Models.PayeeLocation)
  def handle_call({:get_all_transactions, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/transactions", Models.Transaction)
  def handle_call({:get_account_transactions, budget_id, account_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/accounts/#{account_id}/transactions", Models.Transaction)
  def handle_call({:get_category_transactions, budget_id, category_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/categories/#{category_id}/transactions", Models.HybridTransaction)
  def handle_call({:get_payee_transactions, budget_id, payee_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/payees/#{payee_id}/transactions", Models.HybridTransaction)
  def handle_call({:get_transaction, budget_id, transaction_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/transactions/#{transaction_id}", Models.Transaction)
  def handle_call({:get_scheduled_transactions, budget_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/scheduled_transactions", Models.ScheduledTransaction)
  def handle_call({:get_scheduled_transaction, budget_id, transaction_id}, _from, access_token), do:
    request_and_parse_case(access_token, "#{@base_url}/budgets/#{budget_id}/scheduled_transactions/#{transaction_id}", Models.ScheduledTransaction)

  @impl GenServer
  def handle_info(:timeout, access_token) do
    {:stop, {:shutdown, :timeout}, access_token}
  end

  @impl GenServer
  def terminate({:shutdown, response = %HTTPoison.Response{status_code: status_code}}, _access_token) do
    Logger.warn("Received invalid response from api (#{status_code})", [
      status_code: status_code,
      response: response
    ])
  end
  def terminate({:shutdown, error = %HTTPoison.Error{reason: reason}}, _access_token) do
    Logger.warn("HTTPoison failed:\n#{reason}", [
      reason: reason,
      error: error
    ])
  end
  def terminate({:shutdown, error = %Jason.DecodeError{}}, _access_token) do
    Logger.warn("YNAB api returned invalid payload", [
      error: error
    ])
  end
  def terminate({:shutdown, :timeout}, _access_token), do: nil
  def terminate(reason, _access_token), do: reason

  # Helper functions

  @spec get_name(binary()) :: GenServer.name()
  defp get_name(access_token), do: {:via, Registry, {Registry.Workers, access_token}}

  @spec get_headers(binary()) :: keyword(binary())
  defp get_headers(access_token), do: [
    "Authorization": "Bearer #{access_token}",
    "Accept": "Application/json; Charset=utf-8"
  ]

  @spec request_and_parse_case(binary(), binary(), module()) :: {:reply, struct(), binary()} | {:reply, list(struct()), binary()} | {:reply, {:error, any()}, binary()}
  defp request_and_parse_case(access_token, url, model) do
    case request_and_parse(access_token, url, model) do
      result = {:ok, %^model{}} ->
        {:reply, result, access_token}
      result = {:ok, [%^model{} | _tail]} ->
        {:reply, result, access_token}
      result = {:ok, []} ->
        {:reply, result, access_token}
      error_tuple = {:error, _error} ->
        {:reply, error_tuple, access_token}
    end
  end

  @spec request_and_parse(binary(), binary(), module()) :: {:ok, struct()} | {:ok, list(struct())} | {:error, HTTPoison.Response.t} | {:error, HTTPoison.Error.t} | {:error, Jason.DecodeError.t}
  defp request_and_parse(access_token, url, model) do
    headers = get_headers(access_token)

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        apply(model, :parse, [body])
      {:ok, response = %HTTPoison.Response{}} ->
        {:error, response}
      {:error, error = %HTTPoison.Error{}} ->
        {:error, error}
    end
  end
end
