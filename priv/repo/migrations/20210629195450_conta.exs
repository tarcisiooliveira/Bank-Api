defmodule BankApi.Repo.Migrations.Conta do
  use Ecto.Migration

  def change do
    create table(:contas) do
      add :saldo_conta,    :integer, null: false
      add :tipo_contas_id, references(:tipo_contas, null: false)
      add :moedas_id,      references(:moedas, null: false)
      add :usuarios_id,    references(:usuarios, null: false)
      add :operacoes_id,   references(:operacoes, null: false)

      timestamps()
    end
  end
end
