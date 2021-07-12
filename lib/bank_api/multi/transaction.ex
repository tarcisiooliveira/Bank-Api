defmodule BankApi.Multi.Transaction do
  @moduledoc """
    This Module valid manipulations of Transactions and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.{Transaction, Account, Operation}
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Account, as: HandleAccountRepo
  alias BankApi.Handle.Repo.Operation, as: HandleOperationRepo
  alias BankApi.Handle.Repo.Transaction, as: HandleTransactionRepo
  alias BankApi.SendEmail.SendEmail

  def create(%{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:same_account, fn _, _ ->
        case is_same_account?(from_account_id, to_account_id) do
          true -> {:error, :transfer_para_account_origem}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:negative_value, fn _, _ ->
        case is_negative_value?(value) do
          true -> {:error, :value_zero_or_negative}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ -> fetch_account(%{id: from_account_id}) end)
      |> Ecto.Multi.run(:operation, fn _, _ -> fetch_operation(%{id: operation_id}) end)
      |> Ecto.Multi.run(:balance_enough, fn _, %{from_account: from_account} ->
        case is_balance_enough?(from_account.balance_account, value) do
          true -> {:ok, :balance_enough}
          false -> {:error, :balance_not_enough}
        end
      end)
      |> Ecto.Multi.run(:to_account, fn _, _ -> fetch_account(%{id: to_account_id}) end)
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
        create_transaction(from_account.id, to_account.id, operation_id, value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        %{
          create_transaction: %Transaction{
            from_account_id: from_account_id,
            to_account_id: to_account_id
          },
          operation: %Operation{operation_name: operation_name}
        } = params

        send_email(from_account_id, to_account_id, operation_name)

        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def create(%{
        from_account_id: from_account_id,
        operation_id: operation_id,
        value: value
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:negative_value, fn _, _ ->
        case is_negative_value?(value) do
          true -> {:error, :value_zero_or_negative}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ -> fetch_account(%{id: from_account_id}) end)
      |> Ecto.Multi.run(:operation, fn _, _ -> fetch_operation(%{id: operation_id}) end)
      |> Ecto.Multi.run(:balance_transcao_insuficiente, fn _, %{from_account: from_account} ->
        case is_balance_enough?(from_account.balance_account, value) do
          true -> {:ok, :balance_enough}
          false -> {:error, :balance_not_enough}
        end
      end)
      |> Ecto.Multi.update(:changeset_balance_account_from, fn %{from_account: from_account} ->
        operation(from_account, value, :sub)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{from_account: from_account} ->
        create_transaction(from_account.id, operation_id, value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        %{
          create_transaction: %Transaction{
            from_account_id: from_account_id
          },
          operation: %Operation{operation_name: operation_name}
        } = params

        send_email(from_account_id, operation_name)
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def delete(%{id: _id} = params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_transaction, fn _, _ ->
        fetch_transaction(params)
      end)
      |> Ecto.Multi.delete(:delete_account, fn %{fetch_transaction: fetch_transaction} ->
        fetch_transaction
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp create_transaction(from_account_id, to_account_id, operation, value) do
    %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      operation_id: operation,
      value: value
    }
    |> Transaction.changeset()
  end

  defp create_transaction(from_account_id, operation_id, value) do
    %{
      from_account_id: from_account_id,
      operation_id: String.to_integer(operation_id),
      value: value
    }
    |> Transaction.changeset()
  end

  defp fetch_account(%{id: _id} = params) do
    case HandleAccountRepo.fetch_account(params) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  defp fetch_transaction(%{id: _id} = params) do
    case HandleTransactionRepo.fetch_transaction(params) do
      nil ->
        {:error, :transaction_not_found}

      transaction ->
        {:ok, transaction}
    end
  end

  defp fetch_operation(%{id: _operation_id} = params) do
    case HandleOperationRepo.fetch_operation(params) do
      nil -> {:error, :operation_not_found}
      operation -> {:ok, operation}
    end
  end

  defp is_same_account?(id_origem, id_destino) do
    id_origem == id_destino
  end

  defp is_negative_value?(value) do
    if value == 0 or Decimal.new(value) |> Decimal.negative?(), do: true, else: false
  end

  defp is_balance_enough?(balance_inicial, value),
    do: if(balance_inicial - String.to_integer(value) >= 0, do: true, else: false)

  defp operation(account, value, :sub) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account() - String.to_integer(value)
    })
  end

  defp operation(account, value, :add) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account() + String.to_integer(value)
    })
  end

  defp send_email(
         from_account_id,
         to_account_id,
         operation_name
       ) do
    SendEmail.send(from_account_id, to_account_id, operation_name)
  end

  defp send_email(
         from_account_id,
         operation_name
       ) do
    SendEmail.send(from_account_id, operation_name)
  end
end
