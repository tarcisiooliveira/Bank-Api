defmodule BankApi.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Account

  @moduledoc """
  Modulo de schema de User
  """
  # Schema com o mesmo name da tabela
  schema "Users" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many(:Account, Account)
    timestamps()
  end

  @request_params [:email, :name, :password]

  def build(params) do
    params
    |> changeset()
    |> apply_action!(:insert)
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_pass_hash
  end

  def update_changeset(User, %{email: _email} = params) do
    User
    |> cast(params, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email, message: "Email already in use.")
  end

  def update_changeset(User, %{name: _name} = params) do
    User
    |> cast(params, [:name])
    |> validate_required([:name])
  end



  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
