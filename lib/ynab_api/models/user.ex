defmodule YnabApi.Models.User do
  @moduledoc """
  This is the YnabApi.Models.User module
  """
  alias YnabApi.Models.User

  @enforce_keys [:id]
  defstruct [:id]

  @type t :: %User{id: binary()}

  @doc """
  Parses User struct from binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, YnabApi.Models.User.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json) do
    case Jason.decode(json, [keys: :atoms!]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{data: %{user: user}}) do
    user = %User{
      id: user.id
    }
    {:ok, user}
  end

  @doc """
  Parses a User struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.User.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %User{}} ->
        result
      {:error, error} ->
        raise error
    end
  end
end
