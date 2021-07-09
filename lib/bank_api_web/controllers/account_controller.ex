defmodule BankApiWeb.AccountController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleAccount

  def show(conn, %{"id" => id}) do
    %{id: String.to_integer(id)}
    |> HandleAccount.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(
        conn,
        %{
          "balance_account" => balance_account,
          "user_id" => user_id,
          "account_type_id" => account_type_id
        }
      ) do
    %{balance_account: balance_account, user_id: user_id, account_type_id: account_type_id}
    |> HandleAccount.create()
    |> handle_response(conn, "create.json", :created)
  end

  def create(
        conn,
        %{
          "user_id" => user_id,
          "account_type_id" => account_type_id
        }
      ) do
    %{user_id: to_integer(user_id), account_type_id: to_integer(account_type_id)}
    |> HandleAccount.create()
    |> handle_response(conn, "create.json", :created)
  end

  def update(conn, %{"id" => id, "balance_account" => balance_account} = _params) do
    %{id: to_integer(id), balance_account: to_integer(balance_account)}
    |> HandleAccount.update()
    |> handle_response(conn, "update.json", :created)
  end

  defp to_integer(number), do: String.to_integer(number)

  def delete(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleAccount.delete()
    |> handle_delete(conn)
  end

  defp handle_response({:ok, account}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, account: account)
  end

  defp handle_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end

  defp handle_delete({:ok, account}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", account: account)
  end

  defp handle_delete({:error, error}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: error)
  end

  defp handle_delete(erro, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: "error")
  end
end
