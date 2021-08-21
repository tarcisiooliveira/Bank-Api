defmodule BankApiWeb.FallbackController do
  use BankApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_changeset.json", changeset: changeset)
  end

  def call(conn, {:error, message}) when message == :transfer_to_the_same_account do
    conn
    |> put_status(400)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Transfer to the same Account")
  end

  def call(conn, {:error, message}) when message == :theres_no_user do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "User not Found")
  end

  def call(conn, {:error, message}) when message == :theres_no_account do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Account not Found")
  end

  def call(conn, {:error, message}) when message == :theres_no_transaction do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Transaction not Found")
  end

  def call(conn, {:error, message}) when message == :invalid_parameters do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Invalid Parameters")
  end

  def call(conn, message) when is_nil(message) do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Not found")
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: message)
  end
end
