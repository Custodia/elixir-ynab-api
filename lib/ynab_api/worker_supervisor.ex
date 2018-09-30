defmodule YnabApi.WorkerSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(access_token) do
    DynamicSupervisor.start_child(__MODULE__, {YnabApi.Worker, [access_token]})
  end

  @spec get_or_start_child(binary()) :: {:ok, pid()} | {:error, :already_present} | {:error, any()}
  def get_or_start_child(access_token) do
    case start_child(access_token) do
      {:ok, pid} ->
        {:ok, pid}
      {:ok, pid, _info} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
      error_tuple ->
        error_tuple
    end
  end

  # Callbacks

  @impl DynamicSupervisor
  def init(initial_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: initial_arg
    )
  end
end
