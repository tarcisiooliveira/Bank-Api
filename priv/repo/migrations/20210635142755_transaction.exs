defmodule BankApi.Repo.Migrations.Transaction do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :from_account_id, references(:accounts, null: false)
      add :to_account_id,  references(:accounts)
      add :value, :integer, null: false
      add :operation_id,  references(:operations, null: false)
      timestamps()
    end
  end

end
