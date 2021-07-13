defmodule BankApi.Repo.Migrations.Account do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :balance_account,    :integer, null: false
      add :user_id,    references(:users, null: false)
      add :account_type_id, references(:account_types, null: false)
      timestamps()
    end
    create unique_index(:accounts, [:user_id, :account_type_id])
  end
end
