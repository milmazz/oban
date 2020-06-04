defmodule MyApp.ExternalService do
  @moduledoc false

  def deliver(_) do
    Enum.random([{:ok, :ignored}, {:error, :reason}])
  end
end
