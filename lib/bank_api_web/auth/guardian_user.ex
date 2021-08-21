defmodule BankApiWeb.Auth.GuardianUser do
  @moduledoc """
  Auth library
  """

  alias BankApi.Repo
  alias BankApi.Users.Schemas.User

  use Guardian, otp_app: :bank_api

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  @spec resource_from_claims(any) :: {:error, :unauthorized} | {:ok, any}
  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Repo.get_by(User, id: id)
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :unauthorized}
  end

  def authenticate(%{"email" => email, "password" => password}) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :unauthorized}
      user -> validate_password(user, password)
    end
  end

  def validate_password(%User{password_hash: hash} = user, password) do
    case Bcrypt.verify_pass(password, hash) do
      true -> create_token(user)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(trainer) do
    {:ok, token, _claim} = encode_and_sign(trainer)
    {:ok, token}
  end
end
