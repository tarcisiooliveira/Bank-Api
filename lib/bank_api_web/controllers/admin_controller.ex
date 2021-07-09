defmodule BankApiWeb.AdminController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleAdmin

  def index(conn, params) do
    params
    |> HandleAdmin.create()
    |> handle_create_response(conn, "create.json")
  end

  def show(conn, %{"id" => id}) do
    id
    |> HandleAdmin.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(
        conn,
        %{
          "email" => email,
          "password" => password,
          "password_confirmation" => password_confirmation
        }
      ) do
    %{email: email, password: password, password_confirmation: password_confirmation}
    |> HandleAdmin.create()
    |> handle_create_response(conn, "create.json")
  end

  def create(
        conn,
        _params
      ) do
    {
      :error,
        "Invalid parameters.
        Required: \"email\" => email, \"password\" => password, \"password_confirmation\" => password_confirmation"
    }
    |> handle_create_response(conn, "create.json")
  end

  def delete(conn, %{"id" => id}) do
    %{id: String.to_integer(id)}
    |> HandleAdmin.delete()
    |> handle_delete(conn)
  end

  def update(conn, %{"id" => id, "email" => email}) do
    %{id: id, email: email}
    |> HandleAdmin.update()
    |> handle_response(conn, "update.json", :ok)
  end

  defp handle_create_response({:ok, admin}, conn, view) do
    conn
    |> put_status(:created)
    |> render(view, admin: admin)
  end

  defp handle_create_response({:error, error} = _params, conn, view) do
    conn
    |> put_status(422)
    |> render("error.json", error: error)
  end

  defp handle_delete({:ok, admin}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", admin: admin)
  end

  defp handle_delete({:error, mensagem}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: mensagem)
  end

  defp handle_response({:ok, admin}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, admin: admin)
  end

  defp handle_response({:error, error} = _error, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end
end
