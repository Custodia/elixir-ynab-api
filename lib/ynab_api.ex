defmodule YnabApi do
  @moduledoc """
  # YnabApi

  This module contains elixir mappings for all YNAB (You Need a Budget) REST api v1 endpoints.
  """

  alias YnabApi.WorkerSupervisor
  alias YnabApi.Models

  @spec get_user(binary()) :: {:ok, %Models.User{}} | {:error, any()}
  @doc """
  Gets user information from YNAB api.

  See YnabApi.Models.User for what data is available.
  """
  def get_user(access_token) do
    case WorkerSupervisor.get_or_start_child(access_token) do
      {:ok, pid} ->
        case GenServer.call(pid, :get_user) do
          result = {:ok, %Models.User{}} ->
            result
          error_tuple = {:error, _error} ->
            error_tuple
        end
      error_tuple -> error_tuple
    end
  end
end
