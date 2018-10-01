defmodule YnabApi do
  @moduledoc """
  # YnabApi

  This module contains elixir mappings for all YNAB (You Need a Budget) REST api v1 endpoints.
  """

  alias YnabApi.WorkerSupervisor
  alias YnabApi.Models

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
  @spec get_budgets(binary()) :: {:ok, list(%Models.BudgetSummary{})} | {:error, any()}
  def get_budgets(access_token), do:
    call_worker(access_token, :get_budgets)

  @doc """
  Gets the settings for a given budget.

  Can specify the UUID of the given budget or the atom :last_used to specify the last used budget.

  See YnabApi.Models.BudgetSettings for what data is available.
  """
  @spec get_budget_settings(binary(), binary() | :last_used) :: {:ok, %Models.BudgetSettings{}} | {:error, any()}
  def get_budget_settings(access_token, :last_used), do:
    get_budget_settings(access_token, "last-used")
  def get_budget_settings(access_token, budget_id), do:
    call_worker(access_token, {:get_budget_settings, budget_id})

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
