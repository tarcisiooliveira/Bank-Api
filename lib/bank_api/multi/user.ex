defmodule BankApi.Multi.User do
  @moduledoc """
    This Module valid manipulations of Users and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.User
  alias BankApi.Repo

  alias Ecto.Changeset

  @doc """
  Validate and persist a new User

  ## Parameters
    * `email` - String User email
    * `password` - String user password
    * `password_validation` - String user password validation

  ## Examples
      iex> create(%{email: email, name: name, password: password, password_validation: password_validation})
      {:ok, %{create_user: %User{}}}
  """
  def create(
        %{
          email: _email,
          name: _name,
          password: _password,
          password_validation: _password_validation
        } = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:create_user_changeset, fn _, _ ->
        case create_user(params) do
          %Changeset{valid?: true} = changeset ->
            {:ok, changeset}

          %Changeset{errors: [email: {error, _}]} ->
            {:error, error}
        end
      end)
      |> Ecto.Multi.insert(:insert_user, fn %{
                                              create_user_changeset: create_user_changeset
                                            } ->
        create_user_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Update an User

  ## Parameters
    `id` - Set the user ID
    `email` - String User email


  ## Examples
      iex> update(%{id: id, email: email})
      {:ok, %{updated_user: %User{}}}

      iex> update(%{id: id, name: name})
      {:ok, %{updated_user: %User{}}}

      iex> update(%{id: invalid_id, email: email})
      {:error, :user_not_exists}

      iex> update(%{id: id, email: invalid_email})
      {:error, :invalid_format_email}
  """
  def update(%{id: id, email: email}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_user_by_id, fn _, _ ->
        case Repo.get_by(User, id: id) do
          nil -> {:error, :user_not_exists}
          user -> {:ok, user}
        end
      end)
      |> Ecto.Multi.run(:fetch_user_by_email, fn _, _ ->
        case Repo.get_by(User, email: email) do
          nil -> {:ok, :theres_no_email}
          _ -> {:error, :email_already_exist}
        end
      end)
      |> Ecto.Multi.run(:user_changeset, fn _, %{fetch_user_by_id: fetch_user_by_id} ->
        fetch_user_by_id
        |> create_changeset(%{email: email})
      end)
      |> Ecto.Multi.update(:updated_user, fn %{user_changeset: user_changeset} ->
        user_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def update(%{id: id, name: name}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_user, fn _, _ ->
        case Repo.get_by(User, id: id) do
          nil -> {:error, :user_not_exists}
          user -> {:ok, user}
        end
      end)
      |> Ecto.Multi.run(:user_changeset, fn _, %{fetch_user: fetch_user} ->
        {:ok,
         fetch_user
         |> update_changeset(%{name: name})}
      end)
      |> Ecto.Multi.update(:updated_user, fn %{user_changeset: user_changeset} ->
        user_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Deleting an User

  ## Parameters
    `id` - Set a valid User id.

  ## Examples

      iex> delete(%{id: id})
      {:ok, %{deleted_user: %User{}}}

      iex> delete(%{id: invalid_id})
      {:error, :user_not_found}
  """
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_user, fn _, _ ->
        case Repo.get_by(User, id: id) do
          nil -> {:error, :user_not_found}
          user -> {:ok, user}
        end
      end)
      |> Ecto.Multi.delete(:delete_user, fn %{fetch_user: fetch_user} ->
        fetch_user
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp create_user(params) do
    params
    |> User.changeset()
  end

  defp update_changeset(user, params) do
    user
    |> User.update_changeset(params)
  end

  defp create_changeset(params, %{email: _email} = email) do
    params
    |> User.update_changeset(email)
    |> case do
      %Changeset{valid?: true} = changeset ->
        {:ok, changeset}

      %Changeset{errors: [email: {"Invalid format email.", _}]} ->
        {:error, :invalid_format_email}
    end
  end
end
