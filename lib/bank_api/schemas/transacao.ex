defmodule BankApi.Schemas.Transacao do
  use Ecto.Schema
  # import Ecto.Changeset
  alias BankApi.Schemas.{Conta, Operacao}
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "transacao" do
    belongs_to :contas, Conta
    # belongs_to :carteiras, Carteira
    belongs_to :operacoes, Operacao
    timestamps()
  end
end
