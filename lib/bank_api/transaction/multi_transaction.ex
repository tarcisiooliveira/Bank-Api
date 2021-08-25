defmodule BankApi.Multi.Transaction do
  @moduledoc """
    This Module valid manipulations of Transactions and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Repo
  alias BankApi.SendEmail.SendEmail

  @doc """
  Validate and persist an Transactio


  ## Examples
      iex> create(%{from_account_id: invalid_from_account_id, to_account_id: to_account_id, value: value})
     {:error, :account_not_found}

      iex> create(%{from_account_id: from_account_id, to_account_id: from_account_id, value: value})
     {:error, :transfer_to_the_same_account}
  """
  def create(%{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        value: value
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:same_account, fn _, _ ->
        is_same_account?(from_account_id, to_account_id)
      end)
      |> Ecto.Multi.run(:negative_value, fn _, _ ->
        is_negative_value?(value)
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ ->
        fetch_account(from_account_id)
      end)
      |> Ecto.Multi.run(:to_account, fn _, _ ->
        fetch_account(to_account_id)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_from, fn %{from_account: from_account} ->
        operation(from_account, value, :sub)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_to, fn %{to_account: to_account} ->
        operation(to_account, value, :add)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{
                                                     from_account: from_account,
                                                     to_account: to_account
                                                   } ->
        create_transaction(from_account.id, to_account.id, value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        SendEmail.send()
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def create(%{
        from_account_id: from_account_id,
        value: value
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:negative_value, fn _, _ ->
        is_negative_value?(value)
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ ->
        fetch_account(from_account_id)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_from, fn %{from_account: from_account} ->
        operation(from_account, value, :sub)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{
                                                     from_account: from_account
                                                   } ->
        create_transaction(from_account.id, value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        SendEmail.send()
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp fetch_account(from_account_id) do
    case Repo.get_by(Account, id: from_account_id) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  defp create_transaction(from_account_id, to_account_id, value) do
    %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      value: value
    }
    |> Transaction.changeset()
  end

  defp create_transaction(from_account_id, value) do
    %{
      from_account_id: from_account_id,
      value: value
    }
    |> Transaction.changeset()
  end

  defp is_same_account?(id_origem, id_destino) do
    case id_origem == id_destino do
      true ->
        {:error, :transfer_to_the_same_account}

      false ->
        {:ok, false}
    end
  end

  defp is_negative_value?(value) do
    if value < 0 or Decimal.new(value) |> Decimal.negative?() do
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

  defp operation(account, value, :add) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account + String.to_integer(value)
    })
  end
end
