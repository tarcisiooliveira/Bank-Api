defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller
  alias BankApi.Handle.HandleTransaction
  alias BankApi.Schemas.Transaction
  alias BankApi.Repo

  def show(conn, %{"id" => id}) do
    %{id: to_integer(id)}
    |> get_transaction()
    |> handle_response(conn, "show.json", :ok)
  end

  def get_transaction(%{id: id}) do
    case Repo.get_by(Transaction, id: id) do
      nil -> {:error, "nvalid ID or inexistent."}
      transaction -> {:ok, transaction}
    end
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
      from_account_id: from_account_id,
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

  defp handle_response({:error, :balance_not_enough}, conn, _view, status) do
    conn
    |> put_status(status)
    |> render("error.json", error: :balance_not_enough)
  end

  defp handle_response(transaction, conn, view, status) do
    conn
    |> put_status(status)
    |> render(view, transaction: transaction)
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
