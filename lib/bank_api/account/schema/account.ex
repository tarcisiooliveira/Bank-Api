defmodule BankApi.Accounts.Schemas.Account do
  @moduledoc """
  Modulo de schema de Accounts
  """

  use Ecto.Schema
  alias BankApi.Users.Schemas.User
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "accounts" do
    field :balance_account, :integer, default: 10_000
    belongs_to(:user, User)
    timestamps()
  end

  @request_params [:balance_account, :user_id]
  @balance_account 0..10_000_000_000

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_inclusion(:balance_account, @balance_account)
  end

  @doc false
  def update_changeset(%__MODULE__{} = account, params) do
    account
    |> cast(params, [:balance_account])
    |> validate_required([:balance_account])
  end
end
