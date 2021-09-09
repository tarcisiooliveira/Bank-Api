defmodule BankApi.Withdraw do
  @moduledoc """
    This Module valid manipulations of Transactions and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Repo
  alias BankApi.SendEmail.SendEmail
  alias BankApi.Transactions.Schemas.Transaction

  @doc """
  Validate and persist an Transactio


  ## Examples
      iex> run(%{value: value})
     {:error, :not_found}

  """
  def run(params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:negative_value, fn _, _ ->
        zero_or_negative_value?(params.value)
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ ->
        get_account(params.from_account_id)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_from, fn %{from_account: from_account} ->
        operation(from_account, params.value, :sub)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{
                                                     from_account: from_account
                                                   } ->
        create_withdraw(from_account.id, params.value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        SendEmail.send()
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp get_account(account_id) do
    case Repo.get_by(Account, id: account_id) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  defp create_withdraw(from_account_id, value) do
    %{
      from_account_id: from_account_id,
      value: value
    }
    |> Transaction.changeset_withdraw()
  end

  defp zero_or_negative_value?(value) do
    if value < 1 or String.to_integer(value) |> Decimal.new() |> Decimal.negative?() do
      {:error, :value_zero_or_negative}
    else
      {:ok, false}
    end
  end

  defp operation(account, value, :sub) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account() - String.to_integer(value)
    })
  end
end
