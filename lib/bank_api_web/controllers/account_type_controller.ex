defmodule BankApiWeb.AccountTypeController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleAccountType


  def show(conn, %{"id" => id}) do
    %{id: String.to_integer(id)}
    |> HandleAccountType.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def delete(conn, %{"id" => id}) do
    %{id: String.to_integer(id)}
    |> HandleAccountType.delete()
    |> handle_response(conn, "delete.json", :ok)
  end

  def update(conn, %{"id" => id, "account_type_name" => account_type_name}) do
    %{id: String.to_integer(id), account_type_name: account_type_name}
    |> HandleAccountType.update()
    |> handle_response(conn, "update.json", :ok)
  end

  def create(conn, %{"account_type_name" => account_type_name}) do
    %{account_type_name: account_type_name}
    |> HandleAccountType.create()
    |> handle_response(conn, "create.json", :created)
  end

  defp handle_response({:ok, account_type}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, account_type: account_type)
  end

  defp handle_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end
end
