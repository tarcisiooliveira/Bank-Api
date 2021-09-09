defmodule BankApi.Admins.SignIn do
  @moduledoc """
  SignIn Admin module
  """

  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Repo
  alias BankApiWeb.Auth.GuardianAdmin

  @doc """
  Valid an Admin

  ## Parameters

    * `email` - String email of the admin
    * `password` - String password of the admin

  ## Examples
      iex> authenticate(%{"email" => "admin@email.com", "password" => "123456"})
      {:ok, "token"}

      iex> create(%{email: "admin@email.com", password: "1234526"})
      {:error, :unauthorized}

      iex> create(%{email: "admin@email.com",  password_confirmation: "123456"})
      {:error, :unauthorized}

      iex> create(%{email: "admin@email.com"})
      {:error, :unauthorized}
  """
  def authenticate(params) do
    case Repo.get_by(Admin, email: params["email"]) do
      nil -> {:error, :unauthorized}
      admin -> validate_password(admin, params["password"])
    end
  end

  defp validate_password(admin, password) do
    case Bcrypt.verify_pass(password, admin.password_hash) do
      true -> create_token(admin)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(admin) do
    {:ok, token, _claim} = GuardianAdmin.encode_and_sign(admin)
    {:ok, token}
  end
end
