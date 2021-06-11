defmodule BankApiWeb.AdminController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleAdmin
  alias BankApiWeb.Auth.Guardian

  # Usado pelo :create nos testes de forma automatica
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

  def create(conn, params) do
    with {:ok, admin} <- HandleAdmin.create(params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(admin) do
      conn
      |> put_status(:created)
      |> render("create.json", %{admin: admin, token: token})
    end
  end

  def delete(conn, %{"id" => id}) do
    id
    |> HandleAdmin.delete()
    |> handle_delete(conn)
  end

  def update(conn, %{"id" => id, "email" => email}) do
    id
    |> HandleAdmin.update(%{email: email})
    |> handle_response(conn, "update.json", :ok)
  end

  def update(conn, %{"id" => id, "nome" => nome}) do
    id
    |> HandleAdmin.update(%{nome: nome})
    |> handle_response(conn, "update.json", :ok)
  end

  defp handle_create_response({:ok, admin}, conn, view) do
    conn
    |> put_status(:created)
    |> render(view, admin: admin)
  end

  defp handle_create_response({:error, error} = _params, conn, view) do
    # {:error, %Ecto.Changeset{errors: errors}} = params
    # {error, _as} = errors[:email]
    conn
    |> put_status(422)
    |> render(view, error: error)
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
