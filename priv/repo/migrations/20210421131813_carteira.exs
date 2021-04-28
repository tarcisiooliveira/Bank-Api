defmodule BankApi.Repo.Migrations.Carteira do
  use Ecto.Migration

  def change do
    create table(:carteira) do
      add :carteira_id, :integer
      add :moeda_id, :string
      add :operacao, :string
      add :saldo_carteira, :integer
      timestamps()
    end
  end
end
