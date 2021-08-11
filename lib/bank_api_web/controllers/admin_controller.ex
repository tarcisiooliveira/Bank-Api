defmodule BankApiWeb.AdminController do
  use BankApiWeb, :controller

  alias BankApiWeb.Auth.GuardianAdmin
  alias BankApi.Multi.Admin, as: MultiAdmin
  alias BankApi.Admins.Schemas.Admin

  action_fallback BankApiWeb.FallbackController

  def sign_in(conn, params) do
    with {:ok, token} <- GuardianAdmin.authenticate(params) do
      conn
      |> put_status(:ok)
      |> put_view(BankApiWeb.AdminView)
      # |> IO.inspect()
      |> render("sign_in.json", token: token)
    end
  end

  def sign_up(
        conn,
        %{
          "email" => email,
          "password" => password,
          "password_validation" => password_validation
        }
      ) do
    params =
      %{email: email, password: password, password_validation: password_validation}
      # |> IO.inspect()

    with {:ok, %{insert_admin: %Admin{id: id, email: email}}} <-
           MultiAdmin.create(params) do
      # IO.inspect("@@@@@@@@@@@@@@@")

      conn
      |> put_status(:ok)
      |> put_view(BankApiWeb.AdminView)
      # |> IO.inspect()
      |> render("sign_up.json", %{id: id, email: email})
    end
  end

  def sign_up(conn, _) do
    # BankApi.Repo.all(BankApi.Admins.Schemas.Admin)
    # |> IO.inspect()

    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.AdminView)
    |> render("error.json", %{
      error: "Invalid parameters."
    })
  end
end
