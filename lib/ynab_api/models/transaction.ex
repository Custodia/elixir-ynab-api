defmodule YnabApi.Models.Transaction do
  @moduledoc """
  This is the YnabApi.Models.Transaction module
  """
  alias YnabApi.Models.Transaction
  alias YnabApi.Models.Subtransaction

  @enforce_keys [:id, :date, :amount, :memo, :cleared, :approved, :flag_color, :account_id, :payee_id, :category_id, :transfer_account_id, :transfer_transaction_id, :import_id, :deleted, :account_name, :payee_name, :category_name, :subtransactions]
  defstruct [:id, :date, :amount, :memo, :cleared, :approved, :flag_color, :account_id, :payee_id, :category_id, :transfer_account_id, :transfer_transaction_id, :import_id, :deleted, :account_name, :payee_name, :category_name, :subtransactions]

  @type transaction_state :: :cleared | :uncleared | :reconciled
  @type flag_color :: :red | :orange | :yellow | :green | :blue | :purple | nil
  @type t :: %Transaction{
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
    account_name: binary(),
    payee_name: binary(),
    category_name: binary(),
    subtransactions: Subtransaction.t()
  }

  @doc """
  Parses Transaction struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, t} | {:ok, list(t)} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t} | no_return()
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
  def parse(json = %{data: %{transaction: transaction}}) do
    transaction_ids = Map.get(json, :transaction_ids, nil)

    {:ok, parse_individual(transaction)}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses Transaction struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.Transaction.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %Transaction{}} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helper

  @spec parse_individual(map()) :: t | no_return()
  defp parse_individual(transaction) do
    %Transaction{
      id: transaction.id,
      date: transaction.date,
      amount: transaction.amount,
      memo: transaction.memo,
      cleared: parse_transaction_state(transaction.cleared),
      approved: transaction.approved,
      flag_color: parse_flag_color(transaction.flag_color),
      account_id: transaction.account_id,
      payee_id: transaction.payee_id,
      category_id: transaction.category_id,
      transfer_account_id: transaction.transfer_account_id,
      transfer_transaction_id: transaction.transfer_transaction_id,
      import_id: transaction.import_id,
      deleted: transaction.deleted,
      account_name: transaction.account_name,
      payee_name: transaction.payee_name,
      category_name: transaction.category_name,
      subtransactions: Subtransaction.parse!(transaction.subtransactions)
    }
  end

  @spec parse_transaction_state(binary()) :: transaction_state() | no_return()
  def parse_transaction_state(transaction_state) do
    case transaction_state do
      "cleared" -> :cleared
      "uncleared" -> :uncleared
      "reconciled" -> :reconciled
      _ -> raise "Invalid transaction state #{transaction_state}"
    end
  end

  @spec parse_flag_color(binary()) :: flag_color() | no_return()
  def parse_flag_color(flag_color) do
    case flag_color do
      "red" -> :red
      "orange" -> :orange
      "yellow" -> :yellow
      "green" -> :green
      "blue" -> :blue
      "purple" -> :purple
      nil -> nil
      _ -> raise "Invalid flag color #{flag_color}"
    end
  end
end
