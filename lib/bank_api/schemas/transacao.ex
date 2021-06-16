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

  def changeset(
        %{
          "conta_origem_id" => _conta_origem_id,
          "conta_destino_id" => _onta_destino_id,
          "operacao_id" => _operacao_id,
          "valor" => _valor
        } = params
      ) do
    %__MODULE__{}
    |> cast(params, [:valor, :conta_origem_id, :conta_destino_id, :operacao_id])
    |> validate_required([:valor, :conta_origem_id, :conta_destino_id, :operacao_id])
  end

  def changeset(
        %{
          "conta_origem_id" => _conta_origem_id,
          "operacao_id" => _operacao_id,
          "valor" => _valor
        } = params
      ) do

    %__MODULE__{}
    |> cast(params, [:conta_origem_id, :operacao_id, :valor])
    |> validate_required([:conta_origem_id, :operacao_id, :valor])
  end
end
