defmodule BankApi.Repo.Migrations.Operacao do
  use Ecto.Migration

  def change do
    create table(:operacoes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :nome_operacao, :string
      timestamps()
  end
  end
end
