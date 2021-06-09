defmodule BankApiWeb.ContaController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleConta

  # def index(conn, params) do
  #   params
  #   |> HandleConta.create()
  #   |> handle_response(conn, "create.json", :created)
  # end

  def show(conn, %{"id" => id}) do
    id
    |> HandleConta.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(
        conn,
        %{
          "saldo_conta" => _100_000,
          "usuario_id" => _usuario_id,
          "tipo_conta_id" => _tipo_conta_id
        } = params
      ) do
    params
    |> HandleConta.create()
    |> handle_response(conn, "create.json", :created)
  end

  def create(
        conn,
        %{
          "usuario_id" => _usuario_id,
          "tipo_conta_id" => _tipo_conta_id
        } = params
      ) do
    params
    |> HandleConta.create()
    |> handle_response(conn, "create.json", :created)
  end

  def update(conn, %{"id" => id, "saldo_conta" => saldo_conta} = _params) do
    id
    |> HandleConta.update(%{saldo_conta: saldo_conta})
    |> handle_response(conn, "update.json", :created)
  end

  def delete(conn, %{"id" => id}) do
    id
    |> HandleConta.delete()
    |> handle_delete(conn)
  end

  defp handle_response({:ok, conta}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, conta: conta)
  end

  defp handle_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end

  defp handle_delete({:ok, conta}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", conta: conta)
  end

  defp handle_delete({:error, error}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: error)
  end
end
