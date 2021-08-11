defmodule BankApi.Repo.Migrations.Account do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all, null: false)
      add :balance_account,    :integer, null: false
      timestamps()
    end
    create unique_index(:accounts, :user_id)
  end
end
