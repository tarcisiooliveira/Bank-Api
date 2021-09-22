defmodule BankApi.Users.CreateUser do
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
      iex> create(%{email: "tarcisio@email.com", name: "Name", password: "123456", password_confirmation: "123456"})
      {"user": {"account": {"balance": 100000, "id": "8f641449-ebfc-48c4-a57f-9c98688c4855"},
      "email": "tarcisio@email.com","id": "bec4dee4-9887-4297-9ef3-9d98feec8d1b" }}

      iex> create(%{email: "", name: "Name", password: "123456", password_confirmation: "123456"})
      {"errors": {"email": ["can't be blank"]}}

      iex> create(%{email: "", name: "Name", password: "123456"})
      {"errors": {"email": ["can't be blank"],"password_confirmation": ["can't be blank"]}}

      iex> create(%{email: "email@email.com", name: "Name", password: "1234561", password_confirmation: "123456"})
      {"errors": { "password_confirmation": ["Passwords are different."]}}
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
