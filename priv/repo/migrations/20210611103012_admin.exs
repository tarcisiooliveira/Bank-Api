defmodule BankApi.Repo.Migrations.Admin do
  use Ecto.Migration

  def change do
    create table(:admins, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create(unique_index(:admins, [:email]))
  end
end
