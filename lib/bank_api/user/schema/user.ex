defmodule BankApi.Users.Schemas.User do
  @moduledoc """
  Modulo de schema de User
  """
  alias BankApi.Accounts.Schemas.Account

  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  # Schema com o mesmo name da tabela
  schema "users" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    has_one :accounts, Account
    timestamps()
  end

  @request_params [:email, :name, :password, :password_confirmation]

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_format(:email, ~r/@/, message: "Email format invalid.")
    |> unique_constraint(:email, message: "Email already used.")
    |> validate_confirmation(:password, message: "Passwords are different.")
    |> validate_length(:password,
      min: 6,
      max: 10,
      message: "Password must contain between 4 and 10 characters."
    )
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
