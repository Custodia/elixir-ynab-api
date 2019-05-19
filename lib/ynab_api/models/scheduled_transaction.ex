defmodule YnabApi.Models.ScheduledTransaction do
  @moduledoc """
  This is the YnabApi.Models.ScheduledTransaction module
  """
  alias YnabApi.Models.Transaction
  alias YnabApi.Models.ScheduledTransaction
  alias YnabApi.Models.ScheduledSubTransaction

  @enforce_keys [:id, :date_first, :date_next, :frequency, :amount, :memo, :flag_color, :account_id, :payee_id, :category_id, :transfer_account_id, :deleted, :account_name, :payee_name, :category_name, :subtransactions]
  defstruct [:id, :date_first, :date_next, :frequency, :amount, :memo, :flag_color, :account_id, :payee_id, :category_id, :transfer_account_id, :deleted, :account_name, :payee_name, :category_name, :subtransactions]

  @type frequency :: :never | :daily | :weekly | :everyOtherWeek | :twiceAMonth | :every4Weeks | :monthly | :everyOtherMonth | :every3Months | :every4Months | :twiceAYear | :yearly | :everyOtherYear
  @type t :: %ScheduledTransaction{
    id: binary(),
    date_first: binary(),
    date_next: binary(),
    frequency: frequency(),
    amount: integer(),
    memo: binary(),
    flag_color: Transaction.flag_color(),
    account_id: binary(),
    payee_id: binary(),
    category_id: binary(),
    transfer_account_id: binary() | :nil,
    deleted: boolean(),
    account_name: binary(),
    payee_name: binary(),
    category_name: binary(),
    subtransactions: ScheduledSubTransaction.t()
  }

  @doc """
  Parses ScheduledTransaction struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, YnabApi.Models.ScheduledTransaction.t} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{data: %{scheduled_transaction: scheduled_transaction}}) do
    {:ok, parse_individual(scheduled_transaction)}
  end
  def parse(%{data: %{scheduled_transactions: scheduled_transactions}}) do
    scheduled_transactions =
      scheduled_transactions
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, scheduled_transactions}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses ScheduledTransaction struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.ScheduledTransaction.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %ScheduledTransaction{}} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  @spec parse_individual(map()) :: t | no_return()
  defp parse_individual(map = %{}) do
    %ScheduledTransaction{
      id: map.id,
      date_first: map.date_first,
      date_next: map.date_next,
      frequency: parse_frequency(map.frequency),
      amount: map.amount,
      memo: map.memo,
      flag_color: map.flag_color,
      account_id: map.account_id,
      payee_id: map.payee_id,
      category_id: map.category_id,
      transfer_account_id: map.transfer_account_id,
      deleted: map.deleted,
      account_name: map.account_name,
      payee_name: map.payee_name,
      category_name: map.category_name,
      subtransactions: ScheduledSubTransaction.parse!(map.subtransactions)
    }
  end

  @spec parse_frequency(binary()) :: frequency()
  defp parse_frequency(frequency) do
    case frequency do
      "never" -> :never
      "daily" -> :daily
      "weekly" -> :weekly
      "everyOtherWeek" -> :everyOtherWeek
      "twiceAMonth" -> :twiceAMonth
      "every4Weeks" -> :every4Weeks
      "monthly" -> :monthly
      "everyOtherMonth" -> :everyOtherMonth
      "every3Months" -> :every3Months
      "every4Months" -> :every4Months
      "twiceAYear" -> :twiceAYear
      "yearly" -> :yearly
      "everyOtherYear" -> :everyOtherYear
      _ -> raise "Invalid frequency #{frequency}"
    end
  end
end
