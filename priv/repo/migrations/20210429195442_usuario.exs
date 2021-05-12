defmodule BankApi.Repo.Migrations.Usuario do
  use Ecto.Migration

  def change do
    create table(:usuarios) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :password_hash, :string
      timestamps()
    end
    create unique_index(:usuarios, [:email])
  end
end
