defmodule BankApi.Repo.Migrations.Transacao do
  use Ecto.Migration

  def change do
    create table(:transacoes) do
      add :conta_origem_id, references(:contas, null: false)
      add :conta_destino_id,  references(:contas)
      add :valor, :integer, null: false
      add :operacao_id,  references(:operacoes, null: false)
      timestamps()
    end
  end

end
