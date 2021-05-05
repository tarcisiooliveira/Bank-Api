defmodule BankApi.Schemas.TipoConta do
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "tipo_contas" do
    field :nome_tipo_conta, :string
    timestamps()
  end

end
