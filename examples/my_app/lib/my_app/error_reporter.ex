defmodule MyApp.ErrorReporter do
  @moduledoc false

  alias MyApp.Reportable

  require Logger

  def handle_event([:oban, :job, :exception], _, %{attempt: attempt, worker: worker} = meta, _) do
    if Reportable.reportable?(worker, attempt) do
      _context = Map.take(meta, [:id, :args, :queue, :worker])

      # Honeybadger.notify(meta.error, context, meta.stack)

      Logger.info("Error reported via Honeybadger")
    end
  end
end
