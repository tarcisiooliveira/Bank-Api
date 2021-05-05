defmodule BankApi.Repo.Migrations.Usuario do
  use Ecto.Migration

  def change do
    create table(:usuarios, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :name, :string
      add :password_hash, :string
      timestamps()
    end

  end
end
