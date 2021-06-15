defmodule BankApiWeb.FallbackController do
  use BankApiWeb, :controller

  def error(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BankApiWeb.ErrorView)
    |> render("401.json", error: "Administrador não cadastrado.")
  end

  def error(conn, %{error: error}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BankApiWeb.ErrorView)
    |> render("400.json", error: error)
  end

  def call(conn, params) do
    {conn, params}
  end

end
