defmodule BankApi.Repo.Migrations.Moeda do
  use Ecto.Migration

  def change do
    create table(:moedas, primary_key: false)do
      add :id, :uuid, primary_key: true
      add :cod, :string, null: false
      add :nome_moeda, :string, null: false
      timestamps()
    end
  end
end
