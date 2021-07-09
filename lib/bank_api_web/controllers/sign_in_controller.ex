defmodule BankApiWeb.SignInController do
  use BankApiWeb, :controller

  alias BankApiWeb.Auth.Guardian
  alias BankApiWeb.FallbackController

  def sign_in(conn, params) do
    return = Guardian.authenticate (params)

    case return do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("sign_in.json", token: token)

      {:error, error} ->
        FallbackController.error(conn, %{error: error})
    end
  end
end
