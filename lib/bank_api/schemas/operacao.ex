defmodule BankApi.Schemas.Operacao do
  use Ecto.Schema
  alias BankApi.Schemas.{Conta, Transacao}

  schema "operacao" do
    field :nome_operacao, :string, null: false
    has_many(:conta, Conta)
    has_many(:transacao, Transacao)
    timestamps()
  end
end
