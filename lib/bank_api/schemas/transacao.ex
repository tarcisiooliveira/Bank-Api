defmodule BankApi.Schemas.Transacao do
  use Ecto.Schema
  alias BankApi.Schemas.{Conta, Operacao}

  schema "transacao" do
    belongs_to(:conta, Conta)
    belongs_to(:operacao, Operacao)
    timestamps()
  end
end
