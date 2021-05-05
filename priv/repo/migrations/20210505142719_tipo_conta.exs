defmodule BankApi.Repo.Migrations.TipoConta do
  use Ecto.Migration

  def change do
    create table(:tipo_contas, primary_key: false)do
      add :id, :uuid, primary_key: true
      add :nome_tipo_conta, :string, null: false
      timestamps()
    end
  end
end
