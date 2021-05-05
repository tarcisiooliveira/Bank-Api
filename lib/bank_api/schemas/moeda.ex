defmodule BankApi.Schemas.Moeda do
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "moedas" do
    field :cod, :string, null: false
    field :nome_moeda, :string, null: false
    timestamps()
  end
end
