defmodule BankApiWeb.OperationController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleOperation

  def index(conn, params) do
    params
    |> HandleOperation.create()
    |> handle_response(conn, "create.json", :created)
  end

  def show(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleOperation.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(conn, %{"operation_name" => operation_name}) do
    %{operation_name: operation_name}
    |> HandleOperation.create()
    |> handle_response(conn, "create.json", :created)
  end

  def update(conn, %{"id" => id, "operation_name" => operation_name}) do
    %{id: to_integer(id), operation_name: operation_name}
    |> HandleOperation.update()
    |> handle_response(conn, "update.json", :created)
  end

  def delete(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleOperation.delete()
    |> handle_delete(conn)
  end

  defp handle_response({:ok, operation}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, operation: operation)
  end

  defp handle_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end

  defp handle_delete({:ok, operation}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", operation: operation)
  end

  defp handle_delete({:error, error}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: error)
  end

  defp to_integer(value), do: String.to_integer(value)
end
