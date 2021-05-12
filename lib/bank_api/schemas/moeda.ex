defmodule BankApi.Schemas.Moeda do
  use Ecto.Schema
  alias BankApi.Schemas.Conta

  schema "moeda" do
    field :cod, :string, null: false
    field :nome_moeda, :string, null: false
    has_many(:conta, Conta)
    timestamps()
  end
end
