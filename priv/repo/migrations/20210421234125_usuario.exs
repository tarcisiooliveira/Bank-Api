defmodule BankApi.Repo.Migrations.Usuario do
  use Ecto.Migration

  def change do
    create table(:usuario) do
      add :usuario_id, :integer
      add :nome, :string
      add :email, :string
      add :passwor_hash, :string
      timestamps()


    end
  end
end
