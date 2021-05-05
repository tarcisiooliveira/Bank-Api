defmodule BankApi.Repo.Migrations.Transacao do
  use Ecto.Migration

  def change do
    create table(:transacao, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :conta_origem_id, references(:contas, type: :uuid), null: false
      add :conta_destino_id, references(:contas, type: :uuid), null: false
      add :operacao_id, references(:operacoes, type: :uuid), null: false
      timestamps()
  end
  end
end
