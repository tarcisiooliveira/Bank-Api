defmodule BankApi.User.SignIn do
  @moduledoc """
  SignIn User module
  """

  alias BankApi.Repo
  alias BankApi.Users.Schemas.User
  alias BankApiWeb.Auth.GuardianUser, as: GuardianUser

  def authenticate(%{"email" => email, "password" => password}) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :unauthorized}
      user -> validate_password(user, password)
    end
  end

  def validate_password(%User{password_hash: hash} = user, password) do
    case Bcrypt.verify_pass(password, hash) do
      true ->  create_token(user)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(user) do
    {:ok, token, _claim} = GuardianUser.encode_and_sign(user)
    {:ok, token}
  end

end
