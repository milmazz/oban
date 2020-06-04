defmodule MyApp.Workers.ScheduledWorker do
  use Oban.Worker, queue: :scheduled, max_attempts: 10

  alias MyApp.Mailer

  @one_day 60 * 60 * 24

  @impl true
  def perform(%{args: %{"email" => email} = args, attempt: 1}) do
    args
    |> new(schedule_in: @one_day)
    |> Oban.insert!()

    Mailer.deliver_email(email)
  end

  def perform(%{args: %{"email" => email}}) do
    Mailer.deliver_email(email)
  end
end
