defmodule BankApi.Transfer do
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
      iex> run(%{to_account_id: to_account_id, value: value})
     {:error, :not_found}

      iex> run(%{to_account_id: from_account_id, value: value})
     {:error, :transfer_to_the_same_account}
  """
  def run(params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:is_valid_uuid, fn _, _ ->
        valid_uuid(params.to_account_id)
      end)
      |> Ecto.Multi.run(:same_account, fn _, _ ->
        is_same_account?(params.from_account_id, params.to_account_id)
      end)
      |> Ecto.Multi.run(:zero_or_negative_value, fn _, _ ->
        zero_or_negative_value?(params.value)
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ ->
        get_account(params.from_account_id)
      end)
      |> Ecto.Multi.run(:to_account, fn _, _ ->
        get_account(params.to_account_id)
      end)
      |> Ecto.Multi.run(:validate_balance_enought, fn _, %{from_account: from_account} ->
        validate_balance(from_account, params.value, :sub)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_from, fn %{from_account: from_account} ->
        operation(from_account, params.value, :sub)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_to, fn %{to_account: to_account} ->
        operation(to_account, params.value, :add)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{
                                                     from_account: from_account,
                                                     to_account: to_account
                                                   } ->
        create_transfer(from_account.id, to_account.id, params.value)
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

  defp create_transfer(from_account_id, to_account_id, value) do
    %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      value: value
    }
    |> Transaction.changeset_transfer()
  end

  defp is_same_account?(id_origem, id_destino) do
    case id_origem == id_destino do
      true ->
        {:error, :transfer_to_the_same_account}

      false ->
        {:ok, false}
    end
  end

  defp valid_uuid(uuid) do
    case Ecto.UUID.cast(uuid) do
      :error ->
        {:error, :invalid_account_uuid}

      _ ->
        {:ok, :valid_UUID}
    end
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

  defp operation(account, value, :add) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account + String.to_integer(value)
    })
  end

  defp validate_balance(from_account, value, :sub) do
    case operation(from_account, value, :sub) do
      %Ecto.Changeset{errors: [balance_account: {"is invalid", _}]} ->
        {:error, :insuficient_ammount}

      _ ->
        {:ok, :ammount_enought}
    end
  end
end
