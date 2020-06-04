defmodule MyApp.Mailer do
  @moduledoc false

  def notify_admin(_), do: random()

  def weekly_update(_), do: random()

  def deliver_email(_), do: random()

  defp random, do: Enum.random([{:ok, :ignored}, {:error, :reason}])
end
