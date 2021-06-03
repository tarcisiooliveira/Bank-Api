defmodule BankApi.Schemas.TipoConta do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Conta

  @moduledoc """
  Modulo de schema de Tipo Conta
  """
  schema "tipo_contas" do
    field :nome_tipo_conta, :string, null: false
    has_many(:conta, Conta)
    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:nome_tipo_conta])
    |> validate_required(:nome_tipo_conta)
    |> unique_constraint(:nome_tipo_conta)
  end

  def changeset(tipo_conta, %{nome_tipo_conta: _nome_tipo_conta} = params) do
    tipo_conta
    |> cast(params, [:nome_tipo_conta])
    |> validate_required(:nome_tipo_conta)
    |> unique_constraint(:nome_tipo_conta)
  end
end
