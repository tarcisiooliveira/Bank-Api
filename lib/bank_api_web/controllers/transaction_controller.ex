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

  def transfer(conn, %{"to_account_id" => to_account_id, "value" => value}) do
    # when valid_uuid(to_account_id) do
    user = Guardian.Plug.current_resource(conn)
    %Account{id: id} = Repo.get_by!(Account, user_id: user.id)

    params = %{
      from_account_id: id,
      to_account_id: to_account_id,
      value: value
    }

    case Ecto.UUID.cast(to_account_id) do
      :error ->
        :invalid_account_uuid

      _ ->
        with {:ok, transaction} <- MultiTransaction.transfer(params) do
          render(conn, "transfer.json", transaction: transaction)
        end
    end
  end

  def transfer(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Invalid Parameters")
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
  def withdraw(conn, %{"value" => value}) do
    user = Guardian.Plug.current_resource(conn)

    %Account{id: id} = Repo.get_by!(Account, user_id: user.id)

    params = %{
      from_account_id: id,
      value: value
    }

    with {:ok, transaction} <- MultiTransaction.withdraw(params) do
      render(conn, "withdraw.json", transaction: transaction)
    end
  end

  def withdraw(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", message: "Invalid Parameters")
  end
end
