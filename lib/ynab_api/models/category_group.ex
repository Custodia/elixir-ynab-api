defmodule YnabApi.Models.CategoryGroup do
  @moduledoc """
  This is the YnabApi.Models.CategoryGroup module
  """
  alias YnabApi.Models.Category
  alias YnabApi.Models.CategoryGroup

  @enforce_keys [:id, :name, :hidden, :deleted, :categories]
  defstruct [:id, :name, :hidden, :deleted, :categories]

  @type t :: %CategoryGroup{
    id: binary(),
    name: binary(),
    hidden: boolean(),
    deleted: boolean(),
    categories: list(Category.t)
  }

  @doc """
  Parses CategoryGroup struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, list(YnabApi.Models.CategoryGroup.t)} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t} | no_return()
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms!]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(%{data: %{category_groups: category_groups}}) do
    category_groups =
      category_groups
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, category_groups}
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end

  @doc """
  Parses CategoryGroup struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: list(YnabApi.Models.CategoryGroup.t) | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result} ->
        result
      {:error, error} ->
        raise error
    end
  end

  # Helpers

  @spec parse_individual(map()) :: t | no_return()
  defp parse_individual(map = %{}) do
    %CategoryGroup{
      id: map.id,
      name: map.name,
      hidden: map.hidden,
      deleted: map.deleted,
      categories: Category.parse!(map.categories)
    }
  end
end
