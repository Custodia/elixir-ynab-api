defmodule YnabApi.Models.User do
  @moduledoc """
  This is the YnabApi.Models.User module
  """
  alias YnabApi.Models.User

  @enforce_keys [:id]
  defstruct [:id]

  @doc """
  Parses User struct from json payload.
  """
  def parse(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(json) do
    user =
      json
      |> Map.fetch!("data")
      |> Map.fetch!("user")
    user = %User{
      id: Map.fetch!(user, "id")
    }
    IO.inspect user
    {:ok, user}
  end
end
