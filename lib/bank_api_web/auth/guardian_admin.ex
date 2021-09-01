defmodule BankApiWeb.Auth.GuardianAdmin do
  @moduledoc """
  Auth Admin library
  """

  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Repo

  use Guardian, otp_app: :bank_api

  def subject_for_token(admin, _claims) do
    sub = to_string(admin.id)
    {:ok, sub}
  end

  @spec resource_from_claims(any) :: {:error, :unauthorized} | {:ok, any}
  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Repo.get_by(Admin, id: id)
    {:ok, resource}
  catch
    Ecto.NoResultsError -> {:error, :unauthorized}
  end
end
