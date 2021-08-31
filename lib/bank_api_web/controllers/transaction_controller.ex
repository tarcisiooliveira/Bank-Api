defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Repo
  alias BankApi.Multi.Transaction, as: MultiTransaction

  action_fallback(BankApiWeb.FallbackController)

  @doc """
    Show transaction Data

  ## Parameters

    * `id` - Id of transaction

  ## Examples
      iex> show(%{"id" => "12312312312312313"})
      %{
        "message" => "Transaction founded",
        "Transaction" => %{
          "from_account_id" => _,
          "value" => 700
        }
      }
      iex> show(%{"id" => "12312312312312313"})
      %{
       "message" => "Transaction founded",
       "Transaction" => %{
         "from_account_id" => _,
         "to_account_id" => _,
         "value" => 700
       }
      }

      iex> show(%{"id" => "c1960fa0-11ae-47fa-b325-68d94a7d7f5a"})
      %{"error" => %{"message" => ["Transaction not Found"]}}
  """
  def show(conn, params) do
    with {:ok, transaction} <- get_by_id(params["id"]) do
      conn
      |> put_status(:ok)
      |> render("show.json", transaction: transaction)
    end
  end

  defp get_by_id(id) do
    case Repo.get_by(Transaction, id: id) do
      nil -> {:error, :not_found}
      transaction -> {:ok, transaction}
    end
  end

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
        },
        "message" => "Transaction finished successfully"
      }
  """

  def transfer(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    %Account{id: id} = Repo.get_by!(Account, user_id: user.id)

    params = %{
      from_account_id: id,
      to_account_id: params["to_account_id"],
      value: params["value"]
    }

    with {:ok, transaction} <- MultiTransaction.transfer(params) do
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
        },
        "message" => "Transaction finished successfully"
      }

  """
  def withdraw(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    %Account{id: id} = Repo.get_by!(Account, user_id: user.id)

    params = %{
      from_account_id: id,
      value: params["value"]
    }

    with {:ok, transaction} <- MultiTransaction.withdraw(params) do
      render(conn, "withdraw.json", transaction: transaction)
    end
  end
end
