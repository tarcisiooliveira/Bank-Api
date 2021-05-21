defmodule BankApi.Schemas.Conta do
  use Ecto.Schema
  alias BankApi.Schemas.{Usuario, TipoConta}
  import Ecto.Changeset

  schema "contas" do
    field :saldo_conta, :integer, default: 100_000
    belongs_to(:usuario, Usuario)
    belongs_to(:tipo_conta, TipoConta)
    timestamps()
  end

  @request_params [:saldo_conta, :usuario_id, :tipo_conta_id]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
  end
end
