defmodule YnabApi.Worker do
  use GenServer, restart: :transient

  require Logger

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
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, _json} ->
            {:noreply, access_token, @timeout}
          {:error, error = %Jason.DecodeError{}} ->
            {:stop, {:shutdown, error}, access_token}
        end
      {:ok, response = %HTTPoison.Response{}} ->
        {:stop, {:shutdown, response}, access_token}
      {:error, error = %HTTPoison.Error{}} ->
        {:stop, {:shutdown, error}, access_token}
    end
  end

  @impl GenServer
  def handle_info(:timeout, access_token) do
    {:stop, {:shutdown, :timeout}, access_token}
  end

  @impl GenServer
  def terminate({:shutdown, response = %HTTPoison.Response{status_code: status_code}}, _access_token) do
    Logger.warn("Received invalid response from api (#{status_code})", [
      status_code: status_code,
      response: response
    ])
  end
  def terminate({:shutdown, error = %HTTPoison.Error{reason: reason}}, _access_token) do
    Logger.warn("HTTPoison failed:\n#{reason}", [
      reason: reason,
      error: error
    ])
  end
  def terminate({:shutdown, error = %Jason.DecodeError{}}, _access_token) do
    Logger.warn("YNAB api returned invalid payload", [
      error: error
    ])
  end
  def terminate({:shutdown, :timeout}, _access_token), do: nil

  # Helper functions

  defp get_name(access_token), do: {:via, Registry, {Registry.Workers, access_token}}

  defp get_headers(access_token), do: [
    "Authorization": "Bearer #{access_token}",
    "Accept": "Application/json; Charset=utf-8"
  ]
end
