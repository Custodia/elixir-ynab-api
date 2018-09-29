defmodule YnabApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias YnabApi.WorkerSupervisor

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Registry.Workers},
      {DynamicSupervisor, strategy: :one_for_one, name: WorkerSupervisor}
      # Starts a worker by calling: YnabApi.Worker.start_link(arg)
      # {YnabApi.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: YnabApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
