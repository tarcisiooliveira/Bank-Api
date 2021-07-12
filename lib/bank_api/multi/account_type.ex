defmodule BankApi.Multi.AccountType do
  alias BankApi.Schemas.AccountType
  alias BankApi.Repo
  alias BankApi.Handle.Repo.AccountType, as: HandleAccountTypeRepo
  alias Ecto.Changeset

  @moduledoc """
    This Module valid manipulations of Account Type and the persist in DataBase or RollBack if something is worng.
  """
  def create(
        %{
          account_type_name: _name_account_type
        } = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account_type, fn _, _ ->
        case fetch_account_type(params) do
          nil -> {:ok, :account_type_not_exists}
          _ -> {:error, :account_type_already_exists}
        end
      end)
      |> Ecto.Multi.run(:account_type_changeset, fn _, _ ->
        case create_changest(params) do
          %Changeset{valid?: true} = changeset ->
            {:ok, changeset}

          %Changeset{errors: [account_type_name: {error, _}]} ->
            {:error, error}
        end
      end)
      |> Ecto.Multi.insert(:create_account_type, fn %{
                                                      account_type_changeset:
                                                        account_type_changeset
                                                    } ->
        account_type_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def update(%{id: id, account_type_name: account_type_name}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account_type, fn _, _ ->
        case fetch_account_type(%{id: id}) do
          nil -> {:error, :operation_not_exists}
          operation -> {:ok, operation}
        end
      end)
      |> Ecto.Multi.run(:create_account_type_changeset, fn _,
                                                           %{
                                                             fetch_account_type:
                                                               fetch_account_type
                                                           } ->
        fetch_account_type
        |> AccountType.changeset(%{account_type_name: account_type_name})
        |> case do
          %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
          _ -> {:error, "error_create_changeset"}
        end
      end)
      |> Ecto.Multi.update(:update_account_type, fn %{
                                                      create_account_type_changeset:
                                                        create_account_type_changeset
                                                    } ->
        create_account_type_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account_type, fn _, _ ->
        case fetch_account_type(%{id: id}) do
          nil -> {:error, :operation_not_exists}
          operation -> {:ok, operation}
        end
      end)
      |> Ecto.Multi.delete(:delete_operation, fn %{fetch_account_type: fetch_account_type} ->
        fetch_account_type
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp fetch_account_type(params) do
    HandleAccountTypeRepo.fetch_account_type(params)
  end

  defp create_changest(params) do
    params
    |> AccountType.changeset()
  end
end
