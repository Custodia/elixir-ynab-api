defmodule YnabApi.LogFormatter do
  def format(level, message, {_date, time}, metadata) do
    levelpad = if (level === :error), do: " ", else: ""
    time = Logger.Formatter.format_time(time)
    module = Keyword.fetch!(metadata, :module)
    "\n#{time} [#{module}][#{level}] #{levelpad}#{message}"
  end
end
