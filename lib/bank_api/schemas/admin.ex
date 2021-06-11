defmodule BankApi.Schemas.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Modulo de schema do Admin
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc """
  %Admin{"email" => "admin@admin.com",
        "password" => "123456",
        "password_confirmation" => "123456"}
  """
  # def changeset(
  #       %{email: _email, password: _password, password_confirmation: _password_confirmation} =
  #         params \\ %{}
  #     ) do
  #   %__MODULE__{}
  #   |> cast(params, [:email, :password, :password_confirmation])
  #   |> validate_required([:email, :password, :password_confirmation])
  #   |> validate_format(:email, ~r/@/, message: "Email formato inválido")
  #   |> validate_length(:password,
  #     min: 4,
  #     max: 10,
  #     message: "Password deve conter entre 4 e 10 caracteres."
  #   )
  #   |> validate_confirmation(:password, message: "Senhas diferentes.")
  #   |> unique_constraint(:email, message: "Email já em uso.")
  #   |> put_password()
  # end

  def changeset(
        %{
          "email" => _email,
          "password" => _password,
          "password_confirmation" => _password_confirmation
        } = params \\ %{}
      ) do
    %__MODULE__{}
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/, message: "Email formato inválido")
    |> validate_length(:password,
      min: 4,
      max: 10,
      message: "Password deve conter entre 4 e 10 caracteres."
    )
    |> validate_confirmation(:password, message: "Senhas diferentes.")
    |> unique_constraint(:email, message: "Email já em uso.")
    |> put_password()
  end

  defp put_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
  end

  defp put_password(changeset), do: changeset
end
