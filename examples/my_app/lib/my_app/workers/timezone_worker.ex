defmodule MyApp.Workers.TimezoneWorker do
  use Oban.Worker

  import Ecto.Query

  alias MyApp.{Repo, User}

  @backfill_delay 1

  @impl true
  def perform(%{args: %{"id" => id, "backfill" => true}}) do
    with :ok <- perform(%{args: %{"id" => id}}) do
      case fetch_next(id) do
        next_id when is_integer(next_id) ->
          %{id: next_id, backfill: true}
          |> new(schedule_in: @backfill_delay)
          |> Oban.insert!()

        nil ->
          :ok
      end
    end
  end

  def perform(%{args: %{"id" => id}}) do
    update_timezone(id)
  end

  defp fetch_next(current_id) do
    User
    |> where([u], is_nil(u.timezone))
    |> where([u], u.id > ^current_id)
    |> order_by(asc: :id)
    |> limit(1)
    |> select([u], u.id)
    |> Repo.one()
  end

  defp update_timezone(_id), do: Enum.random([:ok, {:error, :reason}])
end
