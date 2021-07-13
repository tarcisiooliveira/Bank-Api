defmodule BankApi.Schemas.Account do
  @moduledoc """
  Modulo de schema de Accounts
  """

  use Ecto.Schema

  alias BankApi.Schemas.{User, AccountType}

  import Ecto.Changeset

  schema "accounts" do
    field(:balance_account, :integer, default: 100_000)
    belongs_to(:user, User)
    belongs_to(:account_type, AccountType)
    timestamps()
  end

  @request_params [:balance_account, :user_id, :account_type_id]
  @balance_account 0..10_000_000

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_inclusion(:balance_account, @balance_account)
  end

  def update_changeset(%__MODULE__{} = account, %{balance_account: _balance} = params) do
    account
    |> cast(params, [:balance_account])
    |> validate_required([:balance_account])
  end
end
