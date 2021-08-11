defmodule BankApiWeb.FallbackController do
  use BankApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_changeset.json", changeset: changeset)
  end

  def call(conn, message) when is_nil(message) do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Not found")
  end

  def call(conn, {:error, message}) when is_nil(message) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: message)
  end
end
