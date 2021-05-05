defmodule BankApi.Schemas.Operacao do
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "operacoes" do
    field :nome_operacao, :string, null: false
    timestamps()
  end
end
