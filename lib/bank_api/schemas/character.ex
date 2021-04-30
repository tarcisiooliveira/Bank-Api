defmodule BankApi.Schemas.Character do
  use Ecto.Schema

  schema "characters" do
    field :name, :string
    belongs_to :movies, BankApi.Schemas.Movies
  end
end
