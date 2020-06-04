defmodule MyApp.Endpoint do
  @moduledoc false

  def broadcast(_pubsub, _topic, _message), do: :ok
end
