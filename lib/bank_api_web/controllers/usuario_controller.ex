defmodule BankApiWeb.UsuariosController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleUsuario

  def delete(conn, %{"id" => id}) do
    id
    |> HandleUsuario.delete()
    |> handle_delete(conn)
  end

  def update(conn, %{"id" => id, "email" => email}) do
    id
    |> HandleUsuario.update(%{email: email})
    |> handle_response(conn, "update.json", :ok)
  end

  def update(conn, %{"id" => id, "nome" => nome}) do
    id
    |> HandleUsuario.update(%{nome: nome})
    |> handle_response(conn, "update.json", :ok)
  end

  def show(conn, %{"id" => id}) do
    id
    |> HandleUsuario.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(conn, params) do
    params
    |> HandleUsuario.create()
    |> handle_create_response(conn, "create.json")
  end

  # Usado pelo :create nos testes de forma automatica
  def index(conn, params) do
    params
    |> HandleUsuario.create()
    |> handle_create_response(conn, "create.json")
  end

  defp handle_create_response({:ok, usuario}, conn, view) do
    conn
    |> put_status(:created)
    |> render(view, usuario: usuario)
  end

  defp handle_create_response({:error, error} = _params, conn, view) do
    conn
    |> put_status(422)
    |> render(view, error: error)
  end

  defp handle_delete({:ok, usuario}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", usuario: usuario)
  end

  defp handle_delete({:error, mensagem}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: mensagem)
  end

  defp handle_response({:ok, usuario}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, usuario: usuario)
  end

  defp handle_response({:error, error} = _error, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end
end
