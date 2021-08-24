defmodule BankApi.Admin.SignIn do
  @moduledoc """
  SignIn Admin module
  """

  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Repo
  alias BankApiWeb.Auth.GuardianAdmin, as: GuardianAdmin

  def authenticate(%{"email" => email, "password" => password}) do

    case Repo.get_by(Admin, email: email) do
      nil -> {:error, :unauthorized}
      admin -> validate_password(admin, password)
    end
  end

  def validate_password(%Admin{password_hash: hash} = admin, password) do
    case Bcrypt.verify_pass(password, hash) do
      true ->  create_token(admin)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(admin) do
    {:ok, token, _claim} = GuardianAdmin.encode_and_sign(admin)
    {:ok, token}
  end
end
