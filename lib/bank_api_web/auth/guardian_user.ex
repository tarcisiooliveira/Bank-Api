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

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Repo.get_by(User, id: id)
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :unauthorized}
  end
end
