defmodule BankApiWeb.FallbackController do
  use BankApiWeb, :controller

  def call(
        conn,
        {:error, %Ecto.Changeset{errors: [email: {"has already been taken", _}]} = _changeset}
      ) do
        IO.inspect("7")
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Email in use. Choose another.")
  end

  def call(conn, {:error, message}) when message == :transfer_to_the_same_account do
    IO.inspect("6")
    conn
    |> put_status(400)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Transfer to the same Account")
  end

  def call(conn, {:error, message}) when message == :theres_no_user do
    IO.inspect("5")
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "User not Found")
  end

  def call(conn, {:error, message}) when message == :theres_no_account do
    IO.inspect("4")
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Account not Found")
  end

  def call(conn, {:error, message}) when message == :theres_no_transaction do
    IO.inspect("3")
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Transaction not Found")
  end

  def call(conn, message) when is_nil(message) do
    IO.inspect("2")
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Not found")
  end

  def call(conn, {:error, _message}) do
    IO.inspect("1")
    conn
    |> put_status(:unauthorized)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", error: "ASDASDASDASDASD")
  end
end
