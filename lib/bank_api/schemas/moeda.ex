defmodule BankApi.Schemas.Moeda do
  use Ecto.Schema

  schema "moeda" do
    field :moeda_id, :string
    field :moeda_cod, :string
    field :nome, :string

    timestamps()
    # has_many :characters, Friends.Character
    # has_one :distributor, Friends.Distributor
  end
end
