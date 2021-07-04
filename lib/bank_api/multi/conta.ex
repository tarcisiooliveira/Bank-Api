defmodule BankApi.Multi.Conta do
  alias BankApi.Schemas.Conta
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Conta, as: HandleContaRepo
  alias BankApi.Handle.Repo.Usuario, as: HandleUserRepo
  alias BankApi.Handle.Repo.TipoConta, as: HandleAccountTypeRepo

  def create(
        %{saldo_conta: ammount, usuario_id: user_id, tipo_conta_id: account_type_id} = params
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

  def create(%{usuario_id: user_id, tipo_conta_id: account_type_id} = params) do
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

  def update(%{id: id, saldo_conta: ammount}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:ammount_non_negative, fn _, _ ->
        case is_ammount_non_negative?(ammount) do
          false -> {:error, :ammount_negative_value}
          true -> {:ok, :ammount_positive_value}
        end
      end)
      |> Ecto.Multi.run(:fetch_account, fn _, _ ->
        case HandleContaRepo.fetch_account(%{id: id}) do
          nil -> {:error, :theres_no_account}
          account -> {:ok, account}
        end
      end)
      |> Ecto.Multi.update(:update_account, fn %{fetch_account: account} ->
        Conta.update_changeset(account, %{saldo_conta: ammount})
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @spec delete(%{:id => any, optional(any) => any}) :: {:error, any} | {:ok, any}
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account, fn _, _ ->
        case HandleContaRepo.fetch_account(%{id: id}) do
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
         saldo_conta: amount,
         usuario_id: user_id,
         tipo_conta_id: account_type_id
       }) do
    {:ok,
     %{saldo_conta: amount, usuario_id: user_id, tipo_conta_id: account_type_id}
     |> Conta.changeset()}
  end

  defp create_account(%{
         usuario_id: user_id,
         tipo_conta_id: account_type_id
       }) do
    {:ok,
     %{usuario_id: user_id, tipo_conta_id: account_type_id}
     |> Conta.changeset()}
  end
end
