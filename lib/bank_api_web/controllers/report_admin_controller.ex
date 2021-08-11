defmodule BankApiWeb.ReportController do
  use BankApiWeb, :controller

  alias BankApi.Multi.Admin, as: MultiAdmin
  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Repo

  action_fallback BankApiWeb.FallbackController

  def show(conn, %{"email" => email}) do
    with {:ok, admin} <- Repo.get_by(Admin, email: email) do
      render(conn, "show.json", admin: admin)
    end
  end

  def create(
        conn,
        %{
          "email" => email,
          "password" => password,
          "password_validation" => password_validation
        }
      ) do
    params = %{email: email, password: password, password_validation: password_validation}
    with {:ok, admin} <- MultiAdmin.create(params) do
      render(conn, "create.json", admin: admin)
    end
  end
end
