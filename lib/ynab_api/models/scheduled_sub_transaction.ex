defmodule YnabApi.Models.ScheduledSubTransaction do
  @moduledoc """
  This is the YnabApi.Models.ScheduledSubTransaction module
  """
  alias YnabApi.Models.ScheduledSubTransaction

  @enforce_keys [:id, :scheduled_transaction_id, :amount, :memo, :payee_id, :category_id, :transfer_account_id, :deleted]
  defstruct [:id, :scheduled_transaction_id, :amount, :memo, :payee_id, :category_id, :transfer_account_id, :deleted]

  @type t :: %ScheduledSubTransaction{
    id: binary(),
    scheduled_transaction_id: binary(),
    amount: integer(),
    memo: binary(),
    payee_id: binary(),
    category_id: binary(),
    transfer_account_id: binary(),
    deleted: boolean()
  }

  @doc """
  Parses ScheduledSubTransaction struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map() | list(map())) :: {:ok, t} | {:ok, list(t)} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(list) when is_list(list) do
    sub_transactions =
      list
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, sub_transactions}
  end
  def parse(map = %{}) do
    {:ok, parse_individual(map)}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses ScheduledSubTransaction struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map() | list(map())) :: t | list(t) | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  defp parse_individual(map = %{}) do
    %ScheduledSubTransaction{
      id: map.id,
      scheduled_transaction_id: map.scheduled_transaction_id,
      amount: map.amount,
      memo: map.memo,
      payee_id: map.payee_id,
      category_id: map.category_id,
      transfer_account_id: map.transfer_account_id,
      deleted: map.deleted
    }
  end
end
