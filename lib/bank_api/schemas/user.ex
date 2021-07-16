defmodule BankApi.Schemas.User do
  @moduledoc """
  Modulo de schema de User
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias BankApi.Schemas.Account

  # Schema com o mesmo name da tabela
  schema "users" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many(:account, Account)
    timestamps()
  end

  @request_params [:email, :name, :password]

  @doc false
  def build(params) do
    params
    |> changeset()
    |> apply_action!(:insert)
  end

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_pass_hash
  end

  def update_changeset(user, %{email: _email} = params) do
    user
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/, message: "Invalid format email.")
    |> unique_constraint(:email, message: "Email already in use.")
  end

  def update_changeset(user, %{name: _name} = params) do
    user
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
