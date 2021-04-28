defmodule BankApi.Schemas.Operacao do
  use Ecto.Schema

  schema "operacao" do
    field :operacao_id, :integer
    field :tipo_operacao, :string
    timestamps()

  end
end
