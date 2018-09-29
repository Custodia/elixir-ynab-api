defmodule YnabApi.Worker do
  use GenServer, restart: :transient

  @base_url "https://api.youneedabudget.com/v1"
  @timeout 900000 # 15 minutes

  def start_link(access_token) do
    name = get_name(access_token)
    GenServer.start_link(__MODULE__, access_token, name: name)
  end

  # Callbacks

  @impl GenServer
  def init(access_token) do
    {:ok, access_token, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, access_token) do
    url = "#{@base_url}/user"
    headers = get_headers(access_token)

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: _body}} ->
        {:noreply, access_token, @timeout}
      {:ok, response = %HTTPoison.Response{}} ->
        {:stop, response, access_token}
      {:error, error = %HTTPoison.Error{}} ->
        {:stop, error, access_token}
    end
  end

  @impl GenServer
  def handle_info(:timeout, access_token) do
    {:stop, :shutdown, access_token}
  end

  @impl GenServer
  def terminate(%HTTPoison.Response{status_code: status_code}, _access_token) do
    IO.puts "Received invalid response from api (status code: #{status_code})"
  end
  def terminate(%HTTPoison.Error{reason: reason}, _access_token) do
    IO.puts "HTTPoison failed:"
    IO.inspect reason
  end
  def terminate(reason = :normal, _access_token), do: reason
  def terminate(reason = :shutdown, _access_token), do: reason
  def terminate(reason = {:shutdown, _term}, _access_token), do: reason
  def terminate(reason, _access_token) do
    IO.puts "#{__MODULE__} exited unexpectedly with reason:"
    IO.inspect reason
    reason
  end

  # Helper functions

  defp get_name(access_token), do: {:via, Registry, {Registry.Workers, access_token}}

  defp get_headers(access_token), do: [
    "Authorization": "Bearer #{access_token}",
    "Accept": "Application/json; Charset=utf-8"
  ]
end
