defmodule BankApi.Repo.Migrations.Operacao do
  use Ecto.Migration

  def change do
    create table(:operacoes) do
      add :nome_operacao, :string, null: false
      timestamps()
    end
    create unique_index(:operacoes, [:nome_operacao])
  end

end
