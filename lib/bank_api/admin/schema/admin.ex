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

  @doc false
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/, message: "Invalid format email.")
    |> validate_length(:password,
      min: 6,
      max: 10,
      message: "Password must accountin between 4 and 10 characters."
    )
    |> validate_confirmation(:password, message: "Differents password.")
    |> unique_constraint(:email, message: "Email already in use.")
    |> put_password()
  end

  defp put_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password(changeset), do: changeset
end
