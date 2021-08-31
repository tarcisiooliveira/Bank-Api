defmodule BankApi.User.SignIn do
  @moduledoc """
  SignIn User module
  """

  alias BankApi.Repo
  alias BankApi.Users.Schemas.User
  alias BankApiWeb.Auth.GuardianUser, as: GuardianUser

  @doc """
  Valid an Admin

  ## Parameters

    * `email` - String email of the admin
    * `password` - String password of the admin

  ## Examples
      iex> authenticate(%{"email" => "admin@email.com", "password" => "123456"})
     {:ok, "token"}

      iex> create(%{email: "", password: "1234526", password_confirmation: "123456"})
      {:error, :unauthorized}
  """
    def authenticate(params) do
      case Repo.get_by(User, email: params["email"]) do
        nil -> {:error, :unauthorized}
        user -> validate_password(user, params["password"])
    end
  end

  defp validate_password(user, password) do
    case Bcrypt.verify_pass(password, user.password_hash) do
      true -> create_token(user)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(user) do
    {:ok, token, _claim} = GuardianUser.encode_and_sign(user)
    {:ok, token}
  end
end
