defmodule BankApi.Multi.Account do
  @moduledoc """
    This Module valid manipulations of Account and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Users.Schemas.User
  alias Ecto.Multi
  alias BankApi.Repo

  @doc """
  Validate and persist an Account

  ## Parameters
    `ammount` - Integer non negative number
    `user_id` - User owner account id

  ## Examples

      iex> create(%{balance_account: balance_account, user_id: user_id})
      {:ok, %{inserted_account: %Account{}}}

      iex> create(%{balance_account: negative_ammount, user_id: user_id})
      {:error, :ammount_negative_value}


  """
  def create(%{user_id: user_id} = params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:theres_user_account, fn _, _ ->
        case Repo.get_by(User, id: user_id) do
          nil -> {:error, "There's no user with this ID."}
          account -> {:ok, account}
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

  def update(%{balance_account: balance_account, id: account_id}) do
    multi =
      Multi.new()
      |> Ecto.Multi.run(:ammount_non_negative, fn _, _ ->
        case is_ammount_non_negative?(balance_account) do
          false -> {:error, :ammount_negative_value}
          true -> {:ok, :ammount_positive_value}
        end
      end)
      |> Multi.run(:fetch_account, fn _, _ ->
        case Repo.get_by(Account, id: account_id) do
          nil -> {:error, "There's no account with this ID."}
          account -> {:ok, account}
        end
      end)
      |> Multi.update(:update_changeset, fn %{fetch_account: fetch_account} ->
        Account.update_changeset(fetch_account, %{balance_account: balance_account})
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
         user_id: user_id
       }) do
    {:ok,
     %{balance_account: amount, user_id: user_id}
     |> Account.changeset()}
  end

  defp is_ammount_non_negative?(value) do
    if value < 0 or Decimal.new(value) |> Decimal.negative?(), do: false, else: true
  end
end
