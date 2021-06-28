defmodule BankApi.Schemas.Transacao do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.{Conta, Operacao}

  @moduledoc """
  Modulo de schema de Transacao
  """
  schema "transacoes" do
    field :valor, :integer, null: false
    belongs_to(:conta_origem, Conta)
    belongs_to(:conta_destino, Conta)
    belongs_to(:operacao, Operacao)
    timestamps()
  end

  @required_params [:valor, :conta_origem_id, :conta_destino_id, :operacao_id]

  def changeset(
        %{
          conta_origem_id: _conta_origem_id,
          conta_destino_id: _conta_destino_id,
          operacao_id: _operacao_id,
          valor: _valor
        } = params
      ) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  @required_params_saque [:conta_origem_id, :operacao_id, :valor]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params_saque)
    |> validate_required(@required_params_saque)
  end
end
