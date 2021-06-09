defmodule BankApiWeb.TransacaoController do
  use BankApiWeb, :controller
  alias BankApi.Handle.{HandleTransacao, HandleOperacao}
  alias BankApi.Schemas.Operacao

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

  # def update(conn, %{"id" => id, "valor" => valor}) do
  #   id
  #   |> HandleTransacao.update(%{valor: valor})
  #   |> handle_response(conn, "update.json", :ok)
  # end

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
          "operacao_id" => operacao_id,
          "valor" => _valor
        } = params
      ) do
    {:ok, %Operacao{nome_operacao: nome_operacao}} = HandleOperacao.get_name(operacao_id)

    conn = assign(conn, :nome_operacao, nome_operacao)

    params
    |> HandleTransacao.create()
    |> handle_response(conn, "create.json", :created)
  end

  defp handle_response({:ok, transacao}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, transacao: transacao)
  end

  defp handle_delete_response({:ok, transacao}, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, transacao: transacao)
  end

  # defp handle_response({:error, error}, conn, _view, _status) do
  #   conn
  #   |> put_status(:not_found)
  #   |> render("error.json", error: error)
  # end
end
