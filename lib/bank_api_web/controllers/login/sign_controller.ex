defmodule BankApiWeb.SignController do
  use BankApiWeb, :controller

  alias BankApiWeb.Auth.Guardian
  alias BankApiWeb.FallbackController
  alias BankApi.Multi.Admin, as: MultiAdmin
  alias BankApi.Schemas.{Admin, User}

  def sign_in_admin(conn, params) do
    return = Guardian.authenticate(:admin, params)

    case return do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("sign_in_admin.json", token: token)

      {:error, error} ->
        FallbackController.error(conn, %{error: error})
    end
  end

  def sign_up_admin(
        conn,
        %{
          "email" => email,
          "password" => password,
          "password_validation" => password_validation
        } = _params
      ) do
    %{email: email, password: password, password_validation: password_validation}
    |> MultiAdmin.create()
    |> case do
      {:ok, %{insert_admin: %Admin{id: id, email: email}}} ->
        conn
        |> put_status(:ok)
        |> render("sign_up.json", admin: %{id: id, email: email})

      {:error, error} ->
        conn
        |> put_status(:not_found)
        |> render("sign_up.json", %{error: error})
    end
  end
  def sign_in_user(conn, params) do
    return = Guardian.authenticate(:user, params)

    case return do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("sign_in_user.json", token: token)

      {:error, error} ->
        FallbackController.error(conn, %{error: error})
    end
  end
end
