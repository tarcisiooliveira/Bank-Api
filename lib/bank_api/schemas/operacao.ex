defmodule BankApi.Schemas.Operacao do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Transacao

  @moduledoc """
  Modulo de schema de Transacao
  """
  schema "operacoes" do
    field :nome_operacao, :string, null: false
    has_many(:transacao, Transacao)
    timestamps()
  end

  @required_params [:nome_operacao]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(@required_params)
  end

  def update_changeset(%__MODULE__{} = operacao, %{nome_operacao: _nome_operacao}=params) do
    operacao
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(@required_params)
  end
end
