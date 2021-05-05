defmodule BankApi.Repo.Migrations.Conta do
  use Ecto.Migration

  def change do
    create table(:contas) do
      # add :id, :integer, primary_key: true
      add :saldo_conta, :integer
      add :tipo_conta_id, references(:tipo_contas, type: :uuid), null: false
      add :moeda_id, references(:moedas, type: :uuid), null: false
      add :usuarios_id, references(:usuarios, type: :uuid), null: false
      add :operacao_id, references(:operacoes, type: :uuid), null: false
      timestamps()

  end
  end
end
