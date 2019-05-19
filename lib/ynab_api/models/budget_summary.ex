defmodule YnabApi.Models.BudgetSummary do
  @moduledoc """
  This is the YnabApi.Models.BudgetSummary module
  """
  alias YnabApi.Models.BudgetSummary
  alias YnabApi.Models.CurrencyFormat

  @enforce_keys [:id, :name, :first_month, :last_month, :date_format, :currency_format]
  defstruct [:id, :name, :first_month, :last_month, :last_modified_on, :date_format, :currency_format]

  @type t :: %BudgetSummary{
    id: binary(),
    name: binary(),
    first_month: Date.t,
    last_month: Date.t,
    last_modified_on: binary(), # TODO: parse time (it's not ISO8601 formatted..)
    date_format: binary(),
    currency_format: CurrencyFormat.t
  }

  @doc """
  Parses BudgetSummary struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, list(YnabApi.Models.BudgetSummary.t)} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t} | no_return()
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms]) do
      {:ok, json} ->
        parse(json)
      {:error, error} ->
        {:error, error}
    end
  end
  def parse(%{data: %{budgets: budgets}}) do
    budget_summaries =
      budgets
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, budget_summaries}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses BudgetSummary struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: list(YnabApi.Models.BudgetSummary.t) | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result} when is_list(result) ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  @spec parse_individual(map()) :: YnabApi.Models.BudgetSummary.t | no_return()
  defp parse_individual(map = %{}) do
    %BudgetSummary{
      id: map.id,
      name: map.name,
      first_month: Date.from_iso8601!(map.first_month),
      last_month: Date.from_iso8601!(map.last_month),
      last_modified_on: map.last_modified_on,
      date_format: map.date_format.format,
      currency_format: CurrencyFormat.parse!(map.currency_format)
    }
  end
end
