defmodule BankApi.Repo.Migrations.Operation do
  use Ecto.Migration

  def change do
    create table(:operations) do
      add :operation_name, :string, null: false
      timestamps()
    end
    create unique_index(:operations, [:operation_name])
  end

end
