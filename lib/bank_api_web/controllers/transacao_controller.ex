defmodule BankApiWeb.TransacaoController do
  use BankApiWeb, :controller
  alias BankApi.Handle.{HandleTransacao, HandleOperacao}
  alias BankApi.Schemas.{Operacao, Transacao}

  def show(conn, %{"id" => id}) do
    id
    |> HandleTransacao.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def delete(conn, %{"id" => id}) do
    id
    |> HandleTransacao.delete()
    |> handle_delete_response(conn, "delete.json", :ok)
  end

  def create(
        conn,
        %{
          "conta_origem_id" => _conta_origem_id,
          "conta_destino_id" => _onta_destino_id,
          "operacao_id" => _operacao_id,
          "valor" => _valor
        } = params
      ) do
    params
    |> HandleTransacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  def create(
        conn,
        %{
          "conta_origem_id" => _conta_origem_id,
          "operacao_id" => _operacao_id,
          "valor" => _valor
        } = params
      ) do
    params
    |> HandleTransacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  defp handle_response({:ok, transacao}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, transacao: transacao)
  end

  defp handle_delete_response(
         {:ok,
          %Transacao{
            conta_origem_id: conta_origem_id,
            conta_destino_id: conta_destino_id,
            operacao_id: operacao_id,
            valor: valor
          }},
         conn,
         view,
         status
       ) do
    conn
    |> put_status(status)
    |> render(view,
      transacao: %{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }
    )
  end

  defp handle_delete_response({:error, error}, conn, _view, _status) do
    conn
    |> put_status(:not_found)
    |> render("error.json", error: error)
  end
end
