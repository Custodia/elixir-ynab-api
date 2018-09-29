defmodule YnabApi.Worker do
  use GenServer, restart: :transient

  def start_link(personal_access_token) do
    name = get_name(personal_access_token)
    GenServer.start_link(__MODULE__, personal_access_token, name: name)
  end

  # Callbacks

  @impl GenServer
  def init(personal_access_token) do
    {:ok, personal_access_token}
  end

  # Helper functions

  defp get_name(personal_access_token), do: {:via, Registry, {Registry.Workers, personal_access_token}}
end
