defmodule BankApiWeb.Auth.GuardianAdmin do
  @moduledoc """
  Auth Admin library
  """

  alias BankApi.Repo
  alias BankApi.Admins.Schemas.Admin

  use Guardian, otp_app: :bank_api

  def subject_for_token(admin, _claims) do
    sub = to_string(admin.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Repo.get_by(Admin, id: id)
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :unauthorized}
  end

  def authenticate(%{"email" => email, "password" => password}) do
    case Repo.get_by(Admin, email: email) do
      nil -> {:error, "Admin theres no exists."}
      admin -> validate_password(admin, password)
    end
  end

  def validate_password(%Admin{password_hash: hash} = admin, password) do
    case Bcrypt.verify_pass(password, hash) do
      true -> create_token(admin)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(trainer) do
    {:ok, token, _claim} = encode_and_sign(trainer)
    {:ok, token}
  end
end
