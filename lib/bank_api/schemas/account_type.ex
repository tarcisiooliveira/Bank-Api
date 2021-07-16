defmodule BankApi.Schemas.AccountType do
  @moduledoc """
  Module Schema from Account Type
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias BankApi.Schemas.Account

  schema "account_types" do
    field :account_type_name, :string, null: false
    has_many(:account, Account)
    timestamps()
  end

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:account_type_name])
    |> validate_required(:account_type_name)
    |> unique_constraint(:account_type_name)
  end

  @doc false
  def changeset(account_type, %{account_type_name: _account_type_name} = params) do
    account_type
    |> cast(params, [:account_type_name])
    |> validate_required(:account_type_name)
    |> unique_constraint(:account_type_name)
  end
end
