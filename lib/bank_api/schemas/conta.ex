defmodule BankApi.Schemas.Conta do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.{Usuario, TipoConta, Moeda, Operacao}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "contas" do
    field :saldo_conta, :integer

    belongs_to :tipo_contas, TipoConta
    belongs_to :moedas, Moeda
    belongs_to :usuarios, Usuario
    belongs_to :operacoes, Operacao
    timestamps()
  end

  @required [:saldo_conta, :tipo_conta, :usuarios_id]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
