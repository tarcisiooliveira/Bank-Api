defmodule BankApi.Admin.SignIn do
  @moduledoc """
  SignIn Admin module
  """

  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Repo
  alias BankApiWeb.Auth.GuardianAdmin, as: GuardianAdmin

  @doc """
  Valid an Admin

  ## Parameters

    * `email` - String email of the admin
    * `password` - String password of the admin

  ## Examples
      iex> authenticate(%{"email" => "admin@gmail.com", "password" => "123456"})
     {:ok, "token"}

      iex> create(%{email: "", password: "1234526", password_confirmation: "123456"})
      {:error, :unauthorized}
  """
  def authenticate(%{"email" => email, "password" => password} = params) do
    case Repo.get_by(Admin, email: email) do
      nil -> {:error, :unauthorized}
      admin -> validate_password(admin, password)
    end
  end

  defp validate_password(%Admin{password_hash: hash} = admin, password) do
    case Bcrypt.verify_pass(password, hash) do
      true -> create_token(admin)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(admin) do
    {:ok, token, _claim} = GuardianAdmin.encode_and_sign(admin)
    {:ok, token}
  end
end
