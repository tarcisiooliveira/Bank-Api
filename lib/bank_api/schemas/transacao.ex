defmodule BankApi.Schemas.Transacao do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.{Conta, Operacao}

  schema "transacoes" do
    # field :conta_id, :string, null: true
    belongs_to(:conta_origem, Conta)
    belongs_to(:conta_destino, Conta)
    belongs_to(:operacao, Operacao)
    timestamps()
  end

  @request_params [:conta_origem_id, :conta_destino_id, :operacao_id]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
  end
end
