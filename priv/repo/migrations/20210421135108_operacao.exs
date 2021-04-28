defmodule BankApi.Repo.Migrations.Operacao do
  use Ecto.Migration

  def change do
    create table(:operacao) do
      add :operacao_id, :integer
      add :tipo_operacao, :string

      timestamps()
    end
  end
end
