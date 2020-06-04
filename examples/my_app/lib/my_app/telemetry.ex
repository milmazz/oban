defmodule MyApp.Telemetry do
  @moduledoc false
  use Supervisor

  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      summary("oban.job.start.system_time", tags: [:queue], unit: {:native, :millisecond}),
      summary("oban.job.stop.duration", tags: [:queue]),
      summary("oban.job.exception.duration", tags: [:queue])
    ]
  end
end
