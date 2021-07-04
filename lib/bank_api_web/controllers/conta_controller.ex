defmodule BankApiWeb.ContaController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleConta

  def show(conn, %{"id" => id}) do
    %{id: id}
    |> HandleConta.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(
        conn,
        %{
          "saldo_conta" => saldo_conta,
          "usuario_id" => usuario_id,
          "tipo_conta_id" => tipo_conta_id
        }
      ) do
    %{saldo_conta: saldo_conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id}
    |> HandleConta.create()
    |> handle_response(conn, "create.json", :created)
  end

  def create(
        conn,
        %{
          "usuario_id" => usuario_id,
          "tipo_conta_id" => tipo_conta_id
        }
      ) do
    %{usuario_id: to_integer(usuario_id), tipo_conta_id: to_integer(tipo_conta_id)}
    |> HandleConta.create()
    |> handle_response(conn, "create.json", :created)
  end

  def update(conn, %{"id" => id, "saldo_conta" => saldo_conta} = _params) do
    %{id: to_integer(id), saldo_conta: to_integer(saldo_conta)}
    |> HandleConta.update()
    |> handle_response(conn, "update.json", :created)
  end

  defp to_integer(number), do: String.to_integer(number)

  def delete(conn, %{"id" => id}) do
    %{id: to_integer(id)}
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

  defp handle_delete(erro, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: "error")
  end
end
