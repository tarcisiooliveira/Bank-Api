defmodule BankApi.Schemas.Moeda do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Conta

  schema "moedas" do
    field :cod, :string, null: false
    field :nome_moeda, :string, null: false
    has_many(:conta, Conta)
    timestamps()
  end

  @request_params [:cod, :nome_moeda]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_length(:cod, is: 3)
    |> unique_constraint(@request_params)
  end

end
