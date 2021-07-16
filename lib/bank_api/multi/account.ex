defmodule BankApi.Multi.Account do
  @moduledoc """
    This Module valid manipulations of Account and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.{Account, User, Transaction}
  alias BankApi.Repo

  alias BankApi.Schemas.AccountType

  @doc """
  Validate and persist an Account

  ## Parameters
    `ammount` - Integer non negative number
    `user_id` - User owner account id
    `account_type_id` - Id from an Account Type valid.

  ## Examples

      iex> create(%{balance_account: balance_account, user_id: user_id, account_type_id: account_type_id})
      {:ok, %{inserted_account: %Account{}}}

      iex> create(%{balance_account: negative_ammount, user_id: user_id, account_type_id: account_type_id})
      {:error, :ammount_negative_value}

      iex> create(%{balance_account: balance_account, user_id: user_id, account_type_id: pre_existent_account_type_id_by_this_user})
      {:error, :this_user_has_an_account_with_same_account_type_id}
  """
  def create(
        %{balance_account: balance_account, user_id: user_id, account_type_id: account_type_id} =
          params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:ammount_non_negative, fn _, _ ->
        case is_ammount_non_negative?(balance_account) do
          false -> {:error, :ammount_negative_value}
          true -> {:ok, :ammount_positive_value}
        end
      end)
      |> Ecto.Multi.run(:theres_user_account, fn _, _ ->
        case Repo.get_by(User, id: user_id) do
          nil -> {:error, "There's no user with this ID."}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.run(:theres_account_type, fn _, _ ->
        case Repo.get_by(AccountType, id: account_type_id) do
          nil -> {:error, "There's no account type with this ID."}
          account_type -> {:ok, account_type}
        end
      end)
      |> Ecto.Multi.run(:user_has_account_type, fn _, _ ->
        case Repo.get_by(Account, user_id: user_id, account_type_id: account_type_id) do
          nil -> {:ok, "Valid Combination."}
          _account_type -> {:error, :this_user_has_an_account_with_same_account_type_id}
        end
      end)
      |> Ecto.Multi.run(:create_account, fn _, _ ->
        params
        |> create_account()
      end)
      |> Ecto.Multi.insert(:inserted_account, fn %{create_account: account} ->
        account
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def create(%{user_id: user_id, account_type_id: account_type_id} = params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:theres_user_account, fn _, _ ->
        case Repo.get_by(User, id: user_id) do
          nil -> {:error, "There's no user with this ID."}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.run(:theres_account_type, fn _, _ ->
        case Repo.get_by(AccountType, id: account_type_id) do
          nil -> {:error, "There's no account type with this ID."}
          account_type -> {:ok, account_type}
        end
      end)
      |> Ecto.Multi.run(:create_account, fn _, _ ->
        params
        |> create_account()
      end)
      |> Ecto.Multi.insert(:inserted_account, fn %{create_account: account} ->
        account
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Update an Account

  ## Parameters
    `id` - Id of Account
    `user_id` - User owner account id
    `account_type_id` - Id from an Account Type valid.

  ## Examples

      iex> create(%{balance_account: ammount, user_id: user_id, account_type_id: account_type_id})
      {:ok, %{inserted_account: %Account{}}}

      iex> create(%{balance_account: negative_ammount, user_id: user_id, account_type_id: account_type_id})
      {:error, :ammount_negative_value}

      iex> create(%{balance_account: ammount, user_id: user_id, account_type_id: pre_existent_account_type_id_by_this_user})
      {:error, :this_user_has_an_account_with_same_account_type_id}
  """
  def update(%{id: id, balance_account: ammount}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:ammount_non_negative, fn _, _ ->
        case is_ammount_non_negative?(ammount) do
          false -> {:error, :ammount_negative_value}
          true -> {:ok, :ammount_positive_value}
        end
      end)
      |> Ecto.Multi.run(:fetch_account, fn _, _ ->
        case Repo.get_by(Account, id: id) do
          nil -> {:error, :theres_no_account}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.update(:updated_account, fn %{fetch_account: account} ->
        Account.update_changeset(account, %{balance_account: ammount})
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Deleting an Account

  ## Parameters
    * `id` - Account id

  ## Examples

      iex> delete(%{id: id})
      {:ok, %{deleted_account: %Account{}}}

      iex> delete(%{id: invalid_id})
      {:error, :theres_no_account}
  """
  # @spec delete(%{:id => Integer}) :: {:error, :message} | {:ok, :confirmation}
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_transaction_from, fn _, _ ->
        case Repo.get_by(Transaction, from_account_id: id) do
          nil ->
            {:ok, :theres_no_from_transaction}

          _account ->
            {:error, :theres_from_transaction_stored}
        end
      end)
      |> Ecto.Multi.run(:fetch_transaction_to, fn _, _ ->
        case Repo.get_by(Transaction, to_account_id: id) do
          nil ->
            {:ok, :theres_no_to_transaction}
          _account ->
            {:error, :theres_to_transaction_stored}
        end
      end)
      |> Ecto.Multi.run(:fetch_account, fn _, _ ->
        case Repo.get_by(Account, id: id) do
          nil -> {:error, :theres_no_account}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.delete(:deleted_account, fn %{fetch_account: account} ->
        account
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp is_ammount_non_negative?(value) do
    if value < 0 or Decimal.new(value) |> Decimal.negative?(), do: false, else: true
  end

  defp create_account(%{
         balance_account: amount,
         user_id: user_id,
         account_type_id: account_type_id
       }) do
    {:ok,
     %{balance_account: amount, user_id: user_id, account_type_id: account_type_id}
     |> Account.changeset()}
  end

  defp create_account(%{
         user_id: user_id,
         account_type_id: account_type_id
       }) do
    {:ok,
     %{user_id: user_id, account_type_id: account_type_id}
     |> Account.changeset()}
  end
end
