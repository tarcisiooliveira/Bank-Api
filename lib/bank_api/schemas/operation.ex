defmodule BankApi.Schemas.Operation do
  @moduledoc """
  Modulo de schema de Operation
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias BankApi.Schemas.Transaction

  schema "operations" do
    field :operation_name, :string, null: false
    has_many(:transaction, Transaction)
    timestamps()
  end

  @required_params [:operation_name]
  def update_changeset(%__MODULE__{} = operation, %{operation_name: _operation_name} = params) do
    operation
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(@required_params)
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(@required_params)
  end
end
