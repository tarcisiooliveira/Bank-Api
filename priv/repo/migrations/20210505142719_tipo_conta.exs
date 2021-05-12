defmodule BankApi.Repo.Migrations.TipoConta do
  use Ecto.Migration

  def change do
    create table(:tipo_contas)do
      add :nome_tipo_conta, :string, null: false
      timestamps()
    end
    create unique_index(:tipo_contas, [:nome_tipo_conta])
  end
end
