defmodule BankApi.Schemas.Usuario do
  use Ecto.Schema
  alias BankApi.Schemas.Conta

    schema "usuarios" do
      field :email, :string, null: false
      field :name, :string, null: false
      field :password, :string, virtual: true
      field :password_hash, :string
      has_many(:conta, Conta)
      timestamps()
    end

end
