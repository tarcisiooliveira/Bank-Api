defmodule BankApi.Admins.Schemas.Admin do
  @moduledoc """
  Modulo de schema do Admin
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "admins" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @request_params [:email, :password, :password_confirmation]
  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_format(:email, ~r/@/, message: "Email format invalid.")
    |> unique_constraint(:email, message: "Email already in use.")
    |> validate_confirmation(:password, message: "Differents password.")
    |> validate_length(:password,
      min: 6,
      max: 10,
      message: "Password must contain between 4 and 10 characters."
    )
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
