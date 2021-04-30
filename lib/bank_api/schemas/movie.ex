defmodule BankApi.Schemas.Movies do
  use Ecto.Schema

  schema "movies" do
    field :title, :string
    field :tagline, :string
    has_many :characters, BankApi.Schemas.Character
  end
end
