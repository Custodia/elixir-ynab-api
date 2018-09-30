defmodule YnabApi.Models.Error do
  @moduledoc """
  This is the YnabApi.Models.Error module
  """
  alias YnabApi.Models.Error

  @enforce_keys [:id, :name, :detail]
  defstruct [:id, :name, :detail]

  @type t :: %Error{id: binary(), name: binary(), detail: binary()}

  @doc """
  Parses Error struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms!]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{error: error}) do
    error = %Error{
      id: error.id,
      name: error.name,
      detail: error.detail
    }
    {:error, error}
  end

  @doc """
  Parses Error struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` exceot it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.Error.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:error, result = %Error{}} ->
        result
      {:error, error} ->
        raise error
    end
  end
end
