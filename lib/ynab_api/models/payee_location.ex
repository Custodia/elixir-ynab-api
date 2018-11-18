defmodule YnabApi.Models.PayeeLocation do
  @moduledoc """
  This is the YnabApi.Models.PayeeLocation module
  """
  alias YnabApi.Models.PayeeLocation

  @enforce_keys [:id, :payee_id, :latitude, :longitude, :deleted]
  defstruct [:id, :payee_id, :latitude, :longitude, :deleted]

  @type t :: %PayeeLocation{
    id: binary(),
    payee_id: binary(),
    latitude: binary(),
    longitude: binary(),
    deleted: boolean()
  }

  @doc """
  Parses PayeeLocation struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, t} | {:ok, list(t)} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms!]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{data: %{payee_locations: payee_locations}}) do
    payee_locations =
      payee_locations
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, payee_locations}
  end
  def parse(%{data: %{payee_location: payee_location}}) do
    {:ok, parse_individual(payee_location)}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses PayeeLocation struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.PayeeLocation.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %PayeeLocation{}} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  @spec parse_individual(map()) :: t
  defp parse_individual(payee_location = %{}) do
    %PayeeLocation{
      id: payee_location.id,
      payee_id: payee_location.payee_id,
      latitude: payee_location.latitude,
      longitude: payee_location.longitude,
      deleted: payee_location.deleted
    }
  end
end
