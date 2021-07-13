defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleUser

  def show(conn, %{"id" => id}) do
    %{id: String.to_integer(id)}
    |> HandleUser.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(conn, %{
        "name" => name,
        "email" => email,
        "password" => password,
        "password_validation" => password_validation
      }) do
    %{name: name, email: email, password: password, password_validation: password_validation}
    |> HandleUser.create()
    |> handle_create_response(conn, "create.json")
  end

  def delete(conn, %{"id" => id}) do
    %{id: String.to_integer(id)}
    |> HandleUser.delete()
    |> handle_delete(conn)
  end

  def update(conn, %{"id" => id, "email" => email}) do
    %{id: String.to_integer(id), email: email}
    |> HandleUser.update()
    |> handle_response(conn, "update.json", :ok)
  end

  def update(conn, %{"id" => id, "name" => name}) do
    %{id: String.to_integer(id), name: name}
    |> HandleUser.update()
    |> handle_response(conn, "update.json", :ok)
  end

  defp handle_create_response({:ok, user}, conn, view) do
    conn
    |> put_status(:created)
    |> render(view, user: user)
  end

  defp handle_create_response({:error, error} = _params, conn, view) do
    conn
    |> put_status(422)
    |> render(view, error: error)
  end

  defp handle_delete({:ok, user}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", user: user)
  end

  defp handle_delete({:error, message}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: message)
  end

  defp handle_response({:ok, user}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, user: user)
  end

  defp handle_response({:error, error} = _error, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end
end
