defmodule YnabApi.Models.BudgetSettings do
  @moduledoc """
  This is the YnabApi.Models.BudgetSettings module
  """
  alias YnabApi.Models.BudgetSettings
  alias YnabApi.Models.CurrencyFormat

  @enforce_keys [:date_format, :currency_format]
  defstruct [:date_format, :currency_format]

  @type t :: %BudgetSettings{date_format: binary(), currency_format: CurrencyFormat.t}

  @doc """
  Parses BudgetSettings struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, t} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms!]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{data: %{settings: settings = %{}}}) do
    budget_settings = %BudgetSettings{
      date_format: settings.date_format.format,
      currency_format: settings.currency_format
    }

    {:ok, budget_settings}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses BudgetSettings struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.BudgetSettings.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %BudgetSettings{}} ->
        result
      {:error, error} ->
        raise error
    end
  end
end
