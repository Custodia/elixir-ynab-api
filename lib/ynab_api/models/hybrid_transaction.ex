defmodule YnabApi.Models.HybridTransaction do
  @moduledoc """
  This is the YnabApi.Models.HybridTransaction module
  """
  alias YnabApi.Models.Transaction
  alias YnabApi.Models.HybridTransaction

  @enforce_keys [:id, :date, :amount, :memo, :cleared, :approved, :flag_color, :account_id, :payee_id, :category_id, :transfer_account_id, :transfer_transaction_id, :import_id, :deleted, :type, :parent_transaction_id, :account_name, :payee_name, :category_name]
  defstruct [:id, :date, :amount, :memo, :cleared, :approved, :flag_color, :account_id, :payee_id, :category_id, :transfer_account_id, :transfer_transaction_id, :import_id, :deleted, :type, :parent_transaction_id, :account_name, :payee_name, :category_name]

  @type transaction_type :: :transaction | :subtransaction
  @type t :: %HybridTransaction{
    id: binary(),
    date: binary(),
    amount: integer(),
    memo: binary(),
    cleared: Transaction.transaction_state(),
    approved: boolean(),
    flag_color: Transaction.flag_color(),
    account_id: binary(),
    payee_id: binary(),
    category_id: binary(),
    transfer_account_id: binary(),
    transfer_transaction_id: binary(),
    import_id: binary(),
    deleted: boolean(),
    type: HybridTransaction.transaction_type(),
    parent_transaction_id: binary(),
    account_name: binary(),
    payee_name: binary(),
    category_name: binary()
  }

  @doc """
  Parses HybridTransaction struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, t} | {:ok, list(t)} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(json = %{data: %{transactions: transactions}}) do
    server_knowledge = Map.get(json, :server_knowledge, nil)

    transactions =
      transactions
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, transactions}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses HybridTransaction struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.HybridTransaction.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %HybridTransaction{}} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  defp parse_individual(map = %{}) do
    %HybridTransaction{
      id: map.id,
      date: map.date,
      amount: map.amount,
      memo: map.memo,
      cleared: Transaction.parse_transaction_state(map.cleared),
      approved: map.approved,
      flag_color: Transaction.parse_flag_color(map.flag_color),
      account_id: map.account_id,
      payee_id: map.payee_id,
      category_id: map.category_id,
      transfer_account_id: map.transfer_account_id,
      transfer_transaction_id: map.transfer_transaction_id,
      import_id: map.import_id,
      deleted: map.deleted,
      type: map.type,
      parent_transaction_id: map.parent_transaction_id,
      account_name: map.account_name,
      payee_name: map.payee_name,
      category_name: map.category_name
    }
  end
end
