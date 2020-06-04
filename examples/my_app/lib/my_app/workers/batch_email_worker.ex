defmodule MyApp.Workers.BatchEmailWorker do
  use Oban.Worker, queue: :batch, unique: [period: 60]

  import Ecto.Query

  alias MyApp.{Mailer, Repo}

  @final_check_delay 50

  @impl true
  def perform(%{args: %{"email" => email, "batch_id" => batch_id, "batch_size" => batch_size}}) do
    Mailer.weekly_update(email)

    Task.start(fn ->
      Process.sleep(@final_check_delay)

      if final_batch_job?(batch_id, batch_size) do
        %{"status" => "complete", "batch_id" => batch_id}
        |> new()
        |> Oban.insert()
      end
    end)
  end

  def perform(%{args: %{"status" => "complete", "batch_id" => batch_id}}) do
    Mailer.notify_admin("Batch #{batch_id} is complete!")
  end

  defp final_batch_job?(batch_id, batch_size) do
    Oban.Job
    |> where([j], j.state not in ["available", "executing", "scheduled"])
    |> where([j], j.queue == "batch")
    |> where([j], fragment("?->>'batch_id' = ?", j.args, ^batch_id))
    |> where([j], not fragment("? \\? 'status'", j.args))
    |> select([j], count(j.id) >= ^batch_size)
    |> Repo.one()
  end
end
