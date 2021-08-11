defmodule BankApi.Repo.Migrations.Transaction do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :from_account_id, references(:accounts, type: :uuid, null: false)
      add :to_account_id,  references(:accounts, type: :uuid )
      add :value, :integer, null: false
      timestamps()
    end
  end
end
