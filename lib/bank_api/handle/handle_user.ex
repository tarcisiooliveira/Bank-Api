defmodule BankApi.Handle.HandleUser do
  @moduledoc """
  Module to manipulate User by Repo
  """

  alias BankApi.Repo
  alias BankApi.Multi.User, as: MultiUser

  @doc """
  ##Example get user
    iex> get(%{id: valid_id})
    {:ok, %User{}}

    ##Example get - fetch user by id
    iex> get(%{id: invalid_id})
    {:error, "Invalid ID or inexistent."}
  """
  def get(%{id: id}) do
    case Repo.get_by(User, id: id) do
      nil -> {:error, "Invalid ID or inexistent."}
      user -> {:ok, user}
    end
  end

  @spec create(%{
          :email => any,
          :name => any,
          :password => any,
          :password_validation => any,
          optional(any) => any
        }) :: {:error, any} | {:ok, any}
  @doc """
  Set users, create new user
    ##Example
    iex> create(%{name: "Tarta", email: email, password: password, password_validation: password_validation})
    {:ok, %User}

    iex> create(%{name: name, email: email, password: password})
    {:error, reason}
  """
  def create(
        %{
          name: _name,
          email: _email,
          password: _password,
          password_validation: _password_validation
        } = params
      ) do
    params
    |> MultiUser.create()
  end

  @doc """
  Get user id and remove than from database
    ##Example
    iex> delete(%{id: id})
     {:ok, params}

    iex> delete(%{id: invalid_id})
    {:error, error}
  """
  def delete(%{id: _id} = params) do
    params
    |> MultiUser.delete()
  end

  @doc """
  Update
    Set user id and email and update user
    ##Example update email
    iex> update(%{id: id, email: newemail@protonmail.com})
    {:ok, %{updated_user: %User{}}

    iex> update(%{id: id, email: emailinvalid.com})
    {:error, :email_already_exist}

    ##Example update name
    iex> update(%{id: id, name: "New Name"})
    {:ok, %{updated_user:: %User{}}
  """
  def update(%{id: _id, email: _email} = params) do
    params
    |> MultiUser.update()
  end

  def update(%{id: _id, name: _name} = params) do
    params
    |> MultiUser.update()
  end
end
