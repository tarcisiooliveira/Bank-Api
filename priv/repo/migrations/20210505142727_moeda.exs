defmodule BankApi.Repo.Migrations.Moeda do
  use Ecto.Migration

  def change do
    create table(:moedas)do
      add :cod, :string, null: false
      add :nome_moeda, :string, null: false
      timestamps()
    end
    create unique_index(:moedas, [:cod, :nome_moeda])
  end
end
