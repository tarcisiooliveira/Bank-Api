defmodule BankApi.Multi.AccountType do
  @moduledoc """
    This Module valid manipulations of Account Type and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.AccountType
  alias BankApi.Repo
  alias Ecto.Changeset

  @doc """
  Validate and persist a new Account Type

  ## Parameters
    * `account_type_name` - String Account Type Name

  ## Examples

      iex> create(%{account_type_name: name_account_type})
      {:ok, %{create_account_type: AccountType{}}}
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

  @doc """
  Updating an Account Type

  ## Parameters
    * `id` - Account Type id
    * `account_type_name` - String Account Type Name

  ## Examples

      iex> update(%{id: id, account_type_name: name_account_type})
      {:ok, %{update_account_type: AccountType{}}}

      iex> update(%{id: invalid_id, account_type_name: name_account_type})
      {:error, :account_type_not_exists}}
  """
  def update(%{id: id, account_type_name: account_type_name}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account_type, fn _, _ ->
        case fetch_account_type(%{id: id}) do
          nil -> {:error, :account_type_not_exists}
          account_type -> {:ok, account_type}
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

  @doc """
  Deleting an Account Type

  ## Parameters
    * `id` - Account Type id

  ## Examples

      iex> delete(%{id: id})
      {:ok, %{delete_account_type: %AccountType{}}}

      iex> delete(%{id: invalid_id})
      {:error, :account_type_not_exists}}
  """
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_account_type, fn _, _ ->
        case fetch_account_type(%{id: id}) do
          nil -> {:error, :account_type_not_exists}
          account_type -> {:ok, account_type}
        end
      end)
      |> Ecto.Multi.delete(:delete_account_type, fn %{fetch_account_type: fetch_account_type} ->
        fetch_account_type
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp fetch_account_type(params) do
    Repo.get_by(AccountType, params)
  end

  defp create_changest(params) do
    params
    |> AccountType.changeset()
  end
end
