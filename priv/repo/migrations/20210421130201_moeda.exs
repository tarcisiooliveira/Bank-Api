
defmodule BankApi.Repo.Migrations.Moeda do
  use Ecto.Migration

  def change do
    create table(:moeda) do
      add :moeda_id, :string
      add :cod, :string
      add :nome, :string

      timestamps()
    end
  end
end
