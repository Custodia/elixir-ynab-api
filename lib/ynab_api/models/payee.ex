defmodule YnabApi.Models.Payee do
  @moduledoc """
  This is the YnabApi.Models.Payee module
  """
  alias YnabApi.Models.Payee

  @enforce_keys [:id, :name, :transfer_account_id, :deleted]
  defstruct [:id, :name, :transfer_account_id, :deleted]

  @type t :: %Payee{
    id: binary(),
    name: binary(),
    transfer_account_id: binary(),
    deleted: boolean()
  }

  @doc """
  Parses Payee struct from json binary encoded JSON or already decoded JSON.
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
  def parse(%{data: %{payees: payees}}) do
    payees =
      payees
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, payees}
  end
  def parse(%{data: %{payee: payee}}) do
    {:ok, parse_individual(payee)}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses Payee struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: t | list(t) | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  @spec parse_individual(map) :: t
  defp parse_individual(payee = %{}) do
    %Payee{
      id: payee.id,
      name: payee.name,
      transfer_account_id: payee.transfer_account_id,
      deleted: payee.deleted
    }
  end
end
