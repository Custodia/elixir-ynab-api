defmodule YnabApi.WorkerSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(message) do
    DynamicSupervisor.start_child(__MODULE__, {YnabApi.Worker, [message]})
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
