defmodule MyApp.User do
  use Ecto.Schema

  alias Ecto.Changeset

  @required_fields ~w(first_name last_name)a
  @optional_fields ~w(timezone)a

  schema "user" do
    field :first_name
    field :last_name
    field :timezone
  end

  def changeset(user, params \\ %{}) do
    user
    |> Changeset.cast(params, @required_fields ++ @optional_fields)
    |> Changeset.validate_required(@required_fields)
  end
end
