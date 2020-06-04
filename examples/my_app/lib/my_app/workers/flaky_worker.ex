defprotocol MyApp.Reportable do
  @fallback_to_any true
  def reportable?(worker, attempt)
end

defimpl MyApp.Reportable, for: Any do
  def reportable?(_worker, _attempt), do: true
end

defmodule MyApp.Workers.FlakyWorker do
  use Oban.Worker

  defimpl MyApp.Reportable do
    @threshold 3
    def reportable?(_worker, attempt), do: attempt > @threshold
  end

  @impl true
  def perform(%{args: %{"email" => email}}) do
    MyApp.ExternalService.deliver(email)
  end
end
