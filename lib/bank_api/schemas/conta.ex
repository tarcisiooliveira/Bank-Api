defmodule BankApi.Schemas.Conta do
  use Ecto.Schema
  alias BankApi.Schemas.{Usuario, TipoConta}
  import Ecto.Changeset

  @moduledoc """
  Modulo de schema de Contas
  """
  schema "contas" do
    field(:saldo_conta, :integer, default: 100_000)
    belongs_to(:usuario, Usuario)
    belongs_to(:tipo_conta, TipoConta)
    timestamps()
  end

  @request_params [:saldo_conta, :usuario_id, :tipo_conta_id]
  @saldo_conta 0..10_000_000

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_inclusion(:saldo_conta, @saldo_conta)
  end

  def update_changeset(%__MODULE__{} = conta, %{saldo_conta: _saldo} = params) do
    conta
    |> cast(params, [:saldo_conta])
    |> validate_required([:saldo_conta])
  end
end
