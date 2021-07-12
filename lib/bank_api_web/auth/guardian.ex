defmodule BankApiWeb.Auth.Guardian do
  @moduledoc """
  Auth library
  """

  alias BankApi.{Repo, Schemas.Admin}

  use Guardian, otp_app: :bank_api

  def subject_for_token(admin, _claims) do
    sub = to_string(admin.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    claims
    |> Map.get("sub")
    |> BankApi.Handle.HandleAdmin.get()

    # id = claims["sub"]
    # resource = MyApp.get_resource_by_id(id)
    # {:ok, resource}
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
