defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Transfer
  alias BankApi.Users.GetUserAccount
  alias BankApi.Withdraw

  action_fallback(BankApiWeb.FallbackController)

  @doc """
    Transfer values between Accounts

  ## Parameters
    * `conn` - Connection
    * `to_account_id` - Account Id destination,
      `value` - Value

  ## Examples
      iex> transfer(%{"to_account_id" => "UUID_to_account_id", "value" => 1000})
      %{"Transaction" => %{
          "from_account_id" => "UUID_from_account_id",
          "to_account_id" => "UUID_to_account_id"
          "value" => 1000
        }
      }
  """

  def transfer(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, user_account} = GetUserAccount.get_by_id(user.id)

    params = %{
      from_account_id: user_account.accounts.id,
      to_account_id: params["to_account_id"],
      value: params["value"]
    }

    with {:ok, transaction} <- Transfer.run(params) do
      render(conn, "transfer.json", transaction: transaction)
    end
  end

  @doc """
    Withdraw value from Account

    ## Parameters
     `conn` - Connection
     `value` - Value

  ## Examples
      iex> transfer(%{"value" => 1000})
      %{
        "Transaction" => %{
          "from_account_id" => UUID_from_account_id,
          "value" => 1000
        }
      }

  """
  def withdraw(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, user_account} = GetUserAccount.get_by_id(user.id)

    params = %{
      from_account_id: user_account.accounts.id,
      value: params["value"]
    }

    with {:ok, transaction} <- Withdraw.run(params) do
      render(conn, "withdraw.json", transaction: transaction)
    end
  end
end
