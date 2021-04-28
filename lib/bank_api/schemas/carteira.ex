defmodule BankApi.Schemas.Carteira do
  use Ecto.Schema

  schema "carteira" do
    field :moeda_id, :string
    field :carteira_id, :string
    field :operacao, :string
    field :saldo_carteira, :integer

    timestamps()
  end
end
