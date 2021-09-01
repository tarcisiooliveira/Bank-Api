defmodule BankApi.Multi.User do
  @moduledoc """
    This Module valid manipulations of Users and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Repo
  alias BankApi.Users.Schemas.User

  @doc """
  Validate and persist a new User

  ## Parameters
    * `email` - String User email
    * `password` - String user password
    * `password_confirmation` - Same than password

  ## Examples
      iex> create(%{email: "Email@email.com", name: "Name", password: "123456", password_confirmation: "123456"})
      {:ok, %{insert_account: %Account{}, insert_user: %User{}}}

      iex> create(%{email: "", name: "Name", password: "123456", password_confirmation: "123456"})
      {:error, %Changeset{errors: [_], valid?: false}}

      iex> create(%{email: "email@email.com", name: "Name", password: "1234561", password_confirmation: "123456"})
      {:error, %Changeset{errors: [_], valid?: false}}
  """
  def create(params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:insert_user, create_changeset(params))
      |> Ecto.Multi.insert(:insert_account, fn %{insert_user: insert_user} ->
        create_account(insert_user)
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp create_changeset(params) do
    params
    |> User.changeset()
  end

  defp create_account(user) do
    %{user_id: user.id}
    |> Account.changeset()
  end
end
