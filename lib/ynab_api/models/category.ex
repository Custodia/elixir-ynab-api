defmodule YnabApi.Models.Category do
  @moduledoc """
  This is the YnabApi.Models.Category module
  """
  alias YnabApi.Models.Category

  @goal_type_strings [ "TB", "TBD", "MF" ]
  @enforce_keys [:id, :category_group_id, :name, :hidden, :note, :budgeted, :activity, :balance, :goal_type, :goal_creation_month, :goal_target, :goal_target_month, :goal_percentage_complete, :deleted]
  defstruct [:id, :category_group_id, :name, :hidden, :original_category_group_id, :note, :budgeted, :activity, :balance, :goal_type, :goal_creation_month, :goal_target, :goal_target_month, :goal_percentage_complete, :deleted]

  @type goal_type :: :tb | :tbd | :mf | nil
  @type t :: %Category{
    id: binary(),
    category_group_id: binary(),
    name: binary(),
    hidden: boolean(),
    original_category_group_id: binary(),
    note: binary() | nil,
    budgeted: integer(),
    activity: integer(),
    balance: integer(),
    goal_type: goal_type(),
    goal_creation_month: binary() | nil,
    goal_target: integer(),
    goal_target_month: binary() | nil,
    goal_percentage_complete: integer(),
    deleted: boolean()
  }

  @doc """
  Parses Category struct from decoded JSON.
  """
  @spec parse(map()) :: {:ok, list(YnabApi.Models.Category.t)} | no_return()
  def parse(categories) do
    categories =
      categories
      |> Enum.map(&parse_individual/1)
      |> Enum.to_list()

    {:ok, categories}
  end

  @doc """
  Parses Category struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(map()) :: list(YnabApi.Models.Category.t) | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result} ->
        result
    end
  end

  # Helpers

  @spec parse_individual(map()) :: t | no_return()
  defp parse_individual(category = %{}) do
    %Category{
      id: category.id,
      category_group_id: category.category_group_id,
      name: category.name,
      hidden: category.hidden,
      original_category_group_id: category.original_category_group_id,
      note: category.note,
      budgeted: category.budgeted,
      activity: category.activity,
      balance: category.balance,
      goal_type: parse_goal_type(category.goal_type),
      goal_creation_month: category.goal_creation_month,
      goal_target: category.goal_target,
      goal_target_month: category.goal_target_month,
      goal_percentage_complete: category.goal_percentage_complete,
      deleted: category.deleted
    }
  end

  @spec parse_goal_type(binary() | nil) :: goal_type() | no_return()
  defp parse_goal_type(nil), do: nil
  defp parse_goal_type(goal_type_string) when is_binary(goal_type_string) do
    if Enum.member?(@goal_type_strings, goal_type_string) do
      String.to_atom(String.downcase(goal_type_string))
    else
      raise "Invalid goal type #{goal_type_string}"
    end
  end
end
