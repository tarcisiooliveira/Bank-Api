defmodule BankApiWeb.OperacaoController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleOperacao

  def index(conn, params) do
    params
    |> HandleOperacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  def show(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleOperacao.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def create(conn, %{"nome_operacao" => nome_operacao}) do
    %{nome_operacao: nome_operacao}
    |> HandleOperacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  def update(conn, %{"id" => id, "nome_operacao" => nome_operacao}) do
    %{id: to_integer(id), nome_operacao: nome_operacao}
    |> HandleOperacao.update()
    |> handle_response(conn, "update.json", :created)
  end

  def delete(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleOperacao.delete()
    |> handle_delete(conn)
  end

  defp handle_response({:ok, operacao}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, operacao: operacao)
  end

  defp handle_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end

  defp handle_delete({:ok, operacao}, conn) do
    conn
    |> put_status(:ok)
    |> render("delete.json", operacao: operacao)
  end

  defp handle_delete({:error, error}, conn) do
    conn
    |> put_status(:not_found)
    |> render("delete.json", error: error)
  end

  defp to_integer(value), do: String.to_integer(value)
end
