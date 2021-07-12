defmodule BankApi.Schemas.Transaction do
  @moduledoc """
  Modulo de schema de Transaction
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias BankApi.Schemas.{Account, Operation}

  schema "transactions" do
    field :value, :integer, null: false
    belongs_to(:from_account, Account)
    belongs_to(:to_account, Account)
    belongs_to(:operation, Operation)
    timestamps()
  end

  @required_params [:value, :from_account_id, :to_account_id, :operation_id]

  def changeset(
        %{
          from_account_id: _account_origem_id,
          to_account_id: _account_destino_id,
          operation_id: _operation_id,
          value: _value
        } = params
      ) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  @required_params_withdraw [:from_account_id, :operation_id, :value]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params_withdraw)
    |> validate_required(@required_params_withdraw)
  end
end
