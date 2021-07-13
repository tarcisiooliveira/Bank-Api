defmodule BankApiWeb.SignController do
  use BankApiWeb, :controller

  alias BankApiWeb.Auth.Guardian
  alias BankApiWeb.FallbackController
  alias BankApi.Multi.Admin, as: MultiAdmin

  def sign_in(conn, params) do
    return = Guardian.authenticate(params)

    case return do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("sign_in.json", token: token)

      {:error, error} ->
        FallbackController.error(conn, %{error: error})
    end
  end

  def sign_up(
        conn,
        %{
          "email" => _email,
          "password" => _password,
          "password_confirmation" => _password_confirmation
        } = params
      ) do
    case MultiAdmin.create(params) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("sign_up.json", token: token)


      {:error, error} -> FallbackController.error(conn, %{error: error})
    end
  end
end
