defmodule BankApi.Schemas.TipoConta do
  use Ecto.Schema
  alias BankApi.Schemas.Conta

  schema "tipo_conta" do
    field :nome_tipo_conta, :string, null: false
    has_many(:conta, Conta)
    timestamps()
  end
end
