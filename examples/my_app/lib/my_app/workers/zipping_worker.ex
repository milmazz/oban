defmodule MyApp.Workers.ZippingWorker do
  use Oban.Worker, queue: :exports, max_attempts: 1

  alias MyApp.{Endpoint, Zipper}

  def perform(%_{args: %{"channel" => channel, "paths" => paths}}) do
    build_zip(paths)
    await_zip(channel)
  end

  defp build_zip(paths) do
    job_pid = self()

    Task.async(fn ->
      zip_path = Zipper.new()

      paths
      |> Enum.with_index(1)
      |> Enum.each(fn {path, index} ->
        :ok = Zipper.add_file(zip_path, path)
        send(job_pid, {:progress, trunc(index / length(paths) * 100)})
      end)

      send(job_pid, {:complete, zip_path})
    end)
  end

  defp await_zip(channel) do
    receive do
      {:progress, percent} ->
        Endpoint.broadcast(channel, "zip:progress", percent)
        await_zip(channel)

      {:complete, zip_path} ->
        Endpoint.broadcast(channel, "zip:complete", zip_path)
    after
      30_000 ->
        Endpoint.broadcast(channel, "zip:failed", "zipping failed")
        raise RuntimeError, "no progress after 30s"
    end
  end
end
