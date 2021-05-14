defmodule BankApi.Schemas.Operacao do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.{Transacao}

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
    |> unique_constraint(:nome_operacao)
  end
end
