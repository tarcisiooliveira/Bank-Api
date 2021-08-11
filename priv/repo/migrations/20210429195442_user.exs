defmodule BankApi.Repo.Migrations.User do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :name, :string, null: false
      add :password_hash, :string
      timestamps()
    end
    create unique_index(:users, [:email])
  end
end
