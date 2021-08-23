defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Repo
  alias BankApi.Multi.Transaction, as: MultiTransaction
  alias BankApiWeb.Auth.GuardianUser

  action_fallback(BankApiWeb.FallbackController)

  def show(conn) do
    user = GuardianUser.Plug.curent_resource(conn)

    with {:ok, transaction} <- fetch(user.id) do
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

  def transfer(conn, params) do
    user = GuardianUser.Plug.curent_resource(conn)

    params = %{
      from_account_id: user.id,
      to_account_id: params.to_account_id,
      value: params.value
    }

    with {:ok, transaction} <- MultiTransaction.create(params) do
      render(conn, "create.json", transaction: transaction)
    end
  end

  def withdraw(conn, %{"value" => value}) do
    user = GuardianUser.Plug.curent_resource(conn)

    params = %{
      from_account_id: user.id,
      value: value
    }

    with {:ok, transaction} <- MultiTransaction.create(params) do
      render(conn, "create.json", transaction: transaction)
    end
  end
end
