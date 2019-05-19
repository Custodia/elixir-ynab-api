defmodule YnabApi.Models.Account do
  @moduledoc """
  This is the YnabApi.Models.Account module
  """
  alias YnabApi.Models.Account

  @account_type_strings [ "checking", "savings", "cash", "creditCard", "lineOfCredit", "otherAsset", "otherLiability", "payPal", "merchantAccount", "investmentAccount", "mortgage" ]

  @enforce_keys [:id, :name, :type, :on_budget, :closed, :note, :balance, :cleared_balance, :uncleared_balance, :transfer_payee_id, :deleted]
  defstruct [:id, :name, :type, :on_budget, :closed, :note, :balance, :cleared_balance, :uncleared_balance, :transfer_payee_id, :deleted]

  @type account_type :: :checking | :savings | :cash | :creditCard | :lineOfCredit | :otherAsset | :otherLiability | :payPal | :merchantAccount | :investmentAccount | :mortgage
  @type t :: %Account{
    id: binary(),
    name: binary(),
    type: account_type,
    on_budget: boolean(),
    closed: boolean(),
    note: binary(),
    balance: integer(),
    cleared_balance: integer(),
    uncleared_balance: integer(),
    transfer_payee_id: binary(),
    deleted: boolean()
  }

  @doc """
  Parses Account struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, YnabApi.Models.Account.t} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t} | no_return()
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{data: %{accounts: accounts}}) when is_list(accounts) do
    accounts =
      accounts
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, accounts}
  end
  def parse(json = %{data: %{account: account}}), do:
    {:ok, parse_individual(account)}
  def parse(json = %{error: _error}), do:
    YnabApi.Models.Error.parse(json)

  @doc """
  Parses Account struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.Account.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %Account{}} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  @spec parse_individual(map()) :: t | no_return()
  defp parse_individual(map = %{}) do
    %Account{
      id: map.id,
      name: map.name,
      type: parse_account_type(map.type),
      on_budget: map.on_budget,
      closed: map.closed,
      note: map.note,
      balance: map.balance,
      cleared_balance: map.cleared_balance,
      uncleared_balance: map.uncleared_balance,
      transfer_payee_id: map.transfer_payee_id,
      deleted: map.deleted
    }
  end

  @spec parse_account_type(binary) :: account_type | no_return()
  defp parse_account_type(account_type_string) when is_binary(account_type_string) do
    if Enum.member?(@account_type_strings, account_type_string) do
      String.to_atom(account_type_string)
    else
      raise "Invalid account type #{account_type_string}"
    end
  end
end
