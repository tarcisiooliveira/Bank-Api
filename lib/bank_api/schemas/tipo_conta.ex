defmodule BankApi.Schemas.TipoConta do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Conta

  schema "tipo_contas" do
    field :nome_tipo_conta, :string, null: false
    has_many(:conta, Conta)
    timestamps()
  end

  # @spec changeset(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
  #         Ecto.Changeset.t()
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:nome_tipo_conta])
    |> validate_required(:nome_tipo_conta)
    |> unique_constraint(:nome_tipo_conta)
  end
end
