defmodule BankApi.Schemas.Usuario do
  use Ecto.Schema

  schema "usuario" do
    field :usuario_id, :integer
    field :nome, :string
    field :email, :string
    field :passwor_hash, :string

    has_many :conta, BankApi.Schemas.Conta

    timestamps()
  end
end
