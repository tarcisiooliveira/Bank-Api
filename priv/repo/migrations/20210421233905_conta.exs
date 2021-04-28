defmodule BankApi.Repo.Migrations.Conta do
  use Ecto.Migration

  def change do
    create table(:conta) do
      add :conta_id, :integer
      add :id_usuario, :integer
      add :id_carteira, :integer
      add :saldo_conta, :integer

      add :usuario_id, references(:usuario)

      timestamps()
    end
  end
end
