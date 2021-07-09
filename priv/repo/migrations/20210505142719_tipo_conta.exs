defmodule BankApi.Repo.Migrations.TipoAccount do
  use Ecto.Migration

  def change do
    create table(:account_types)do
      add :account_type_name, :string, null: false
      timestamps()
    end
    create unique_index(:account_types, [:account_type_name])
  end
end
