defmodule BankApi.Multi.Transaction do
  alias BankApi.Schemas.{Transaction, Account}
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Account, as: HandleAccountRepo
  alias BankApi.Handle.Repo.Operation, as: HandleOperationRepo
  alias BankApi.Handle.Repo.Transaction, as: HandleTransactionRepo

  def create(%{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:mesma_account, fn _, _ ->
        case is_mesma_account?(from_account_id, to_account_id) do
          true -> {:error, :transferencia_para_account_origem}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:valor_negativo, fn _, _ ->
        case is_negative_value?(value) do
          true -> {:error, :valor_zero_ou_negativo}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ -> buscar_account(%{id: from_account_id}) end)
      |> Ecto.Multi.run(:operation, fn _, _ -> buscar_operation(%{id: operation_id}) end)
      |> Ecto.Multi.run(:balance_insuficiente, fn _, %{from_account: from_account} ->
        case is_balance_suficiente?(from_account.balance_account, value) do
          true -> {:ok, :balance_suficiente}
          false -> {:error, :balance_insuficiente}
        end
      end)
      |> Ecto.Multi.run(:to_account, fn _, _ -> buscar_account(%{id: to_account_id}) end)
      |> Ecto.Multi.update(:changeset_balance_account_origem, fn %{from_account: from_account} ->
        operation(from_account, value, :subtrair)
      end)
      |> Ecto.Multi.update(:changeset_balance_account_destino, fn %{to_account: to_account} ->
        operation(to_account, value, :adicionar)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{
                                                 from_account: from_account,
                                                 to_account: to_account
                                               } ->
        create_transaction(from_account.id, to_account.id, operation_id, value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
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
      |> Ecto.Multi.run(:valor_negativo, fn _, _ ->
        case is_negative_value?(value) do
          true -> {:error, :valor_zero_ou_negativo}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:from_account, fn _, _ -> buscar_account(%{id: from_account_id}) end)
      |> Ecto.Multi.run(:operation, fn _, _ -> buscar_operation(%{id: operation_id}) end)
      |> Ecto.Multi.run(:balance_transcao_insuficiente, fn _, %{from_account: from_account} ->
        case is_balance_suficiente?(from_account.balance_account, value) do
          true -> {:ok, :balance_suficiente}
          false -> {:error, :balance_insuficiente}
        end
      end)
      |> Ecto.Multi.update(:changeset_balance_account_origem, fn %{from_account: from_account} ->
        operation(from_account, value, :subtrair)
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{from_account: from_account} ->
        create_transaction(from_account.id, operation_id, value)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_transaction, fn _, _ -> fetch_transaction(id) end)
      |> Ecto.Multi.delete(:delete_account, fn %{fetch_transaction: Account} ->
        Account
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

  defp buscar_account(%{id: _id} = params) do
    case HandleAccountRepo.fetch_account(params) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  defp fetch_transaction(id) do
    case HandleTransactionRepo.fetch_transaction(id) do
      nil -> {:error, :transaction_not_found}
      Transaction -> {:ok, Transaction}
    end
  end

  defp buscar_operation(%{id: _operation_id} = params) do
    case HandleOperationRepo.fetch_operation(params) do
      nil -> {:error, :operation_not_found}
      operation -> {:ok, operation}
    end
  end

  defp is_mesma_account?(id_origem, id_destino) do
    id_origem == id_destino
  end

  defp is_negative_value?(value) do
    if value == 0 or Decimal.new(value) |> Decimal.negative?(), do: true, else: false
  end

  defp is_balance_suficiente?(balance_inicial, value),
    do: if(balance_inicial - String.to_integer(value) >= 0, do: true, else: false)

  defp operation(account, value, :subtrair) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account() - String.to_integer(value)
    })
  end

  defp operation(account, value, :adicionar) do
    account
    |> Account.update_changeset(%{
      balance_account: account.balance_account() + String.to_integer(value)
    })
  end
end
