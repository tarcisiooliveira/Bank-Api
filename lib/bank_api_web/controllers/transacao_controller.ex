defmodule BankApiWeb.TransacaoController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleTransacao
  alias BankApi.Schemas.Transacao

  def show(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleTransacao.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def delete(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleTransacao.delete()
    |> handle_delete_response(conn, "delete.json", :ok)
  end

  def create(
        conn,
        %{
          "conta_origem_id" => conta_origem_id,
          "conta_destino_id" => conta_destino_id,
          "operacao_id" => operacao_id,
          "valor" => valor
        }
      ) do
    %{
      conta_origem_id: conta_origem_id,
      conta_destino_id: conta_destino_id,
      operacao_id: operacao_id,
      valor: valor
    }
    |> HandleTransacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  def create(
        conn,
        %{
          "conta_origem_id" => conta_origem_id,
          "operacao_id" => operacao_id,
          "valor" => valor
        }
      ) do
    %{
      conta_origem_id: conta_origem_id,
      operacao_id: operacao_id,
      valor: valor
    }
    |> HandleTransacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  defp handle_response(transacao, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, transacao: transacao)
  end

  defp handle_delete_response(
         {:ok,
          %{
            delete_account: %Transacao{
              conta_origem_id: conta_origem_id,
              conta_destino_id: conta_destino_id,
              operacao_id: operacao_id,
              valor: valor
            }
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

  defp to_integer(value), do: String.to_integer(value)
end
