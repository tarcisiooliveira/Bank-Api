defmodule BankApi.Repo.Migrations.Transacao do
  use Ecto.Migration

  def change do
    create table(:transacao) do
      add :registro_id, :integer
      add :id_carteira_origem, :integer
      add :id_carteira_destino, :integer
      add :id_operacao_id, :integer

      timestamps()
    end
  end
end
