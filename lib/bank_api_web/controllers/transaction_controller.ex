defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Repo
  alias BankApi.Multi.Transaction, as: MultiTransaction

  action_fallback BankApiWeb.FallbackController

  def show(conn, %{"id" => id}) do
    with {:ok, transaction} <- fetch(id) do
      conn
      |> put_status(:ok)
      |> render("show.json", transaction: transaction)
    end
  end

  defp fetch(id) do
    case Repo.get_by(Transaction, id: id) do
      nil -> {:error, :theres_no_transaction}
      transaction -> {:ok, transaction}
    end
  end

  def create(
        conn,
        %{
          "from_account_id" => from_account_id,
          "to_account_id" => to_account_id,
          "value" => value
        }
      ) do
    params = %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      value: value
    }

    with {:ok, transaction} <- MultiTransaction.create(params) do
      render(conn, "create.json", transaction: transaction)
    end
  end

  def create(
        conn,
        %{
          "from_account_id" => from_account_id,
          "value" => value
        }
      ) do
    params = %{
      from_account_id: from_account_id,
      value: value
    }

    with {:ok, transaction} <- MultiTransaction.create(params) do
      render(conn, "create.json", transaction: transaction)
    end
  end
end
