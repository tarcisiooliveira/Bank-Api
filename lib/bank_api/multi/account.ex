defmodule BankApi.Multi.Account do
  alias BankApi.Schemas.Account
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Account, as: HandleAccountRepo
  alias BankApi.Handle.Repo.User, as: HandleUserRepo
  alias BankApi.Handle.Repo.AccountType, as: HandleAccountTypeRepo

  def create(
        %{balance_account: ammount, user_id: user_id, account_type_id: account_type_id} = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:ammount_non_negative, fn _, _ ->
        case is_ammount_non_negative?(ammount) do
          false -> {:error, :ammount_negative_value}
          true -> {:ok, :ammount_positive_value}
        end
      end)
      |> Ecto.Multi.run(:theres_user_account, fn _, _ ->
        case HandleUserRepo.fetch_user(%{id: user_id}) do
          nil -> {:error, "There's no user with this ID."}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.run(:theres_account_type, fn _, _ ->
        case HandleAccountTypeRepo.fetch_account_type(%{id: account_type_id}) do
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

  def create(%{user_id: user_id, account_type_id: account_type_id} = params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:theres_user_account, fn _, _ ->
        case HandleUserRepo.fetch_user(%{id: user_id}) do
          nil -> {:error, "There's no user with this ID."}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.run(:theres_account_type, fn _, _ ->
        case HandleAccountTypeRepo.fetch_account_type(%{id: account_type_id}) do
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
        case HandleAccountRepo.fetch_account(%{id: id}) do
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

  @spec delete(%{:id => Integer}) :: {:error, :message} | {:ok, :confirmation}
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account, fn _, _ ->
        case HandleAccountRepo.fetch_account(%{id: id}) do
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

  def is_ammount_non_negative?(value) do
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
