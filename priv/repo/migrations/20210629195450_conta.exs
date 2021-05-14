defmodule BankApi.Repo.Migrations.Conta do
  use Ecto.Migration

  def change do
    create table(:contas) do
      add :saldo_conta,    :integer, null: false
      add :usuario_id,    references(:usuarios, null: false)
      add :tipo_conta_id, references(:tipo_contas, null: false)
      add :moeda_id,      references(:moedas, null: false)
      timestamps()
    end
    create unique_index(:contas, [:usuario_id, :tipo_conta_id, :moeda_id])
  end
end
