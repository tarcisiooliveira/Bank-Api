defmodule BankApiWeb.AccountController do
  use BankApiWeb, :controller

  alias BankApi.Multi.Account, as: MultiAccount
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Repo
  action_fallback BankApiWeb.FallbackController

  def show(conn, %{"email" => email}) do
    with {:ok, account} <- Repo.get_by(Account, email: email) do
      conn
      |> put_status(:ok)
      |> render("show.json", account: account)
    end
  end

  def create(
        conn,
        %{
          "balance_account" => balance_account,
          "user_id" => user_id
        }
      ) do
    params = %{
      balance_account: balance_account,
      user_id: user_id
    }

    with {:ok, account} <- MultiAccount.create(params) do
      render(conn, "create.json", account: account)
    end
  end

  def update(conn, %{"id" => id, "balance_account" => balance_account} = _params) do
    with {:ok, account} <-
           MultiAccount.update(%{id: id, balance_account: String.to_integer(balance_account)}) do
      render(conn, "update.json", account: account)
    end
  end
end
