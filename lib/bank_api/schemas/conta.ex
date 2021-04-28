defmodule BankApi.Schemas.Conta do
  use Ecto.Schema

  schema "conta" do
    field :conta_id, :integer
    field :id_usuario, :integer
    field :id_carteira, :integer
    field :saldo_conta, :integer

    belongs_to :usuario, BankApi.Schemas.Usuario

    timestamps()
  end
end
