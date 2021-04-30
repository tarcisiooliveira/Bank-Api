defmodule BankApi.Repo.Migrations.Conta do
  use Ecto.Migration

  def change do
    create table(:contas, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :conta_id_usuario, :uuid
      add :conta_id_carteira, :uuid
      add :saldo_conta, :integer
      add :usuario_id, references(:usuarios, type: :uuid, on_delete: :delete_all)
      timestamps()

  end
  end
end
