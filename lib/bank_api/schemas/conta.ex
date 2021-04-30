defmodule BankApi.Schemas.Conta do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Usuario

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "contas" do
    field :id_carteira, Ecto.UUID
    field :conta_id_usuario, Ecto.UUID
    field :conta_id_carteira, Ecto.UUID
    field :saldo_conta, :integer
    belongs_to :usuarios, Usuario

    timestamps()
  end

  @required [:saldo_conta]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:saldo_conta])
    |> validate_required([:saldo_conta])
  end
end
