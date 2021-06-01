defmodule BankApiWeb.TipoContaController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleTipoConta

  def show(conn, %{"id" => id}) do
    id
    |> HandleTipoConta.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def delete(conn, %{"id" => id}) do
    id
    |> HandleTipoConta.delete()
    |> handle_response(conn, "delete.json", :ok)
  end

  def update(conn, %{"id" => id, "nome_tipo_conta" => nome_tipo_conta}) do
    id
    |> HandleTipoConta.update(%{nome_tipo_conta: nome_tipo_conta})
    |> handle_response(conn, "update.json", :ok)
  end

  def create(conn, %{"nome_tipo_conta" => _nome_tipo_conta} = params) do
    params
    |> HandleTipoConta.create()
    |> handle_response(conn, "create.json", :created)
  end

  defp handle_response({:ok, tipo_conta}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, tipo_conta: tipo_conta)
  end

  defp handle_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end
end
