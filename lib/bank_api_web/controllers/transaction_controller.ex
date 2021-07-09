defmodule BankApiWeb.TransacaoController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleTransaction
  alias BankApi.Schemas.Transaction

  def show(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleTransaction.get()
    |> handle_response(conn, "show.json", :ok)
  end

  def delete(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> HandleTransaction.delete()
    |> handle_delete_response(conn, "delete.json", :ok)
  end

  def create(
        conn,
        %{
          "from_account_id" => from_account_id,
          "to_account_id" => to_account_id,
          "operation_id" => operation_id,
          "value" => value
        }
      ) do
    %{
      from_account_id: String.to_integer(from_account_id),
      to_account_id: to_account_id,
      operation_id: operation_id,
      value: value
    }
    |> HandleTransaction.create()
    |> handle_response(conn, "create.json", :created)
  end

  def create(
        conn,
        %{
          "from_account_id" => from_account_id,
          "operation_id" => operation_id,
          "value" => value
        }
      ) do
    %{
      from_account_id: from_account_id,
      operation_id: operation_id,
      value: value
    }
    |> HandleTransaction.create()
    |> handle_response(conn, "create.json", :created)
  end

  defp handle_response(Transaction, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, Transaction: Transaction)
  end

  defp handle_delete_response(
         {:ok,
          %{
            delete_account: %Transaction{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              operation_id: operation_id,
              value: value
            }
          }},
         conn,
         view,
         status
       ) do
    conn
    |> put_status(status)
    |> render(view,
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
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
