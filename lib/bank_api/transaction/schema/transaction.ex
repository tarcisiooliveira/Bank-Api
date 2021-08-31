defmodule BankApi.Transactions.Schemas.Transaction do
  @moduledoc """
  Modulo de schema de Transaction
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias BankApi.Accounts.Schemas.Account

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "transactions" do
    field :value, :integer, null: false
    belongs_to(:from_account, Account)
    belongs_to(:to_account, Account)
    timestamps()
  end

  @required_params [:value, :from_account_id, :to_account_id]

  @doc false
  def changeset_transfer(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  @required_params_withdraw [:from_account_id, :value]

  @doc false
  def changeset_withdraw(params) do
    %__MODULE__{}
    |> cast(params, @required_params_withdraw)
    |> validate_required(@required_params_withdraw)
  end
end
