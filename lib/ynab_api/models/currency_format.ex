defmodule YnabApi.Models.CurrencyFormat do
  @moduledoc """
  This is the YnabApi.Models.CurrencyFormat module
  """
  alias YnabApi.Models.CurrencyFormat

  @enforce_keys [:iso_code, :example_format, :decimal_digits, :decimal_separator, :symbol_first, :group_separator, :currency_symbol, :display_symbol]
  defstruct [:iso_code, :example_format, :decimal_digits, :decimal_separator, :symbol_first, :group_separator, :currency_symbol, :display_symbol]

  @type t :: %CurrencyFormat{
    iso_code: binary(),
    example_format: binary(),
    decimal_digits: integer(),
    decimal_separator: binary(),
    symbol_first: boolean(),
    group_separator: binary(),
    currency_symbol: binary(),
    display_symbol: boolean()
  }

  @doc """
  Parses CurrencyFormat struct from json binary encoded JSON or already decoded JSON.
  """
  @spec parse(binary() | map()) :: {:ok, YnabApi.Models.CurrencyFormat.t} | {:error, YnabApi.Models.Error.t} | {:error, Jason.DecodeError.t}
  def parse(json) when is_binary(json)do
    case Jason.decode(json, [keys: :atoms!]) do
      {:ok, json} ->
        parse(json)
      error ->
        error
    end
  end
  def parse(json = %{error: _error}) do
    YnabApi.Models.Error.parse(json)
  end
  def parse(json = %{}) do
    currency_format = %CurrencyFormat{
      iso_code: json.iso_code,
      example_format: json.example_format,
      decimal_digits: json.decimal_digits,
      decimal_separator: json.decimal_separator,
      symbol_first: json.symbol_first,
      group_separator: json.group_separator,
      currency_symbol: json.currency_symbol,
      display_symbol: json.display_symbol
    }

    {:ok, currency_format}
  end

  @doc """
  Parses CurrencyFormat struct from binary encoded JSON or already decoded JSON.

  Similar to `parse/1` except it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(binary() | map()) :: YnabApi.Models.CurrencyFormat.t | no_return()
  def parse!(json) do
    case parse(json) do
      {:ok, result = %CurrencyFormat{}} ->
        result
      {:error, error} ->
        raise error
    end
  end
end
