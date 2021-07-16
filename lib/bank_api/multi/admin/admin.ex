defmodule BankApi.Multi.Admin do
  @moduledoc """
    This Module valid manipulations of Admin and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.Admin
  alias BankApi.Repo
  alias Ecto.Changeset

  @doc """
  Validate and persist a new Admin

  ## Parameters

    * `email` - String email of the admin
    * `password` - String password of the admin
    * `password_validation` - String password_validation of the admin

  ## Examples

      iex> create(%{email: "admin@gmail.com", password: "123456", password_validation: "123456"})
      {:ok, %{inserted_admin: Admin{}}}

      iex> create(%{email: "", password: "123456", password_validation: "123456"})
      {:error, "message"}
  """
  def create(
        %{email: _email, password: _password, password_validation: _password_validation} = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:valid_changeset, fn _, _ ->
        changeset(params)
      end)
      |> Ecto.Multi.insert(:insert_admin, fn %{valid_changeset: valid_changeset} ->
        valid_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Deleting an Admin

  ## Parameters
    `id` - Set a valid admin id.

  ## Examples

      iex> delete(%{id: id})
      {:ok, %{deleted_admin: %Admin{}}}

      iex> delete(%{id: invalid_id})
      {:error, :theres_no_admin}
  """
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_admin, fn _, _ ->
        case Repo.get_by(Admin, id: id) do
          nil -> {:error, :theres_no_admin}
          admin -> {:ok, admin}
        end
      end)
      |> Ecto.Multi.delete(:deleted_admin, fn %{fetch_admin: fetch_admin} ->
        fetch_admin
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Update an Admin email

  ## Parameters
    `id` - Set a valid admin id.
    `email` - Set a valid admin email.

  ## Examples

      iex> update(%{id: id, email: email})
      {:ok, %{update_admin: %Admin{}}}

      iex> delete(%{id: invalid_id, email: "new@email.com"})
      {:error, "Invalid ID or inexistent."}

      iex> delete(%{id: id, email: "newemail.com"})
      {:error, :invalid_format_email}
  """
  @spec update(%{:email => any, :id => any, optional(any) => any}) :: {:error, any} | {:ok, any}
  def update(%{id: id, email: email}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_admin_account, fn _, _ ->
        case Repo.get_by(Admin, id: id) do
          nil ->
            {:error, "Invalid ID or inexistent."}

          admin ->
            {:ok, admin}
        end
      end)
      |> Ecto.Multi.run(:try_admin_by_email, fn _, _ ->
        case Repo.get_by(Admin, email: email) do
          nil ->
            {:ok, "Valid email."}

          _ ->
            {:error, "Email already in use."}
        end
      end)
      |> Ecto.Multi.run(:created_changeset, fn _, %{fetch_admin_account: fetch_admin_account} ->
        fetch_admin_account
        |> create_changeset(%{email: email})
      end)
      |> Ecto.Multi.update(:update_admin, fn %{created_changeset: created_changeset} ->
        created_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp create_changeset(params, %{email: _email} = email) do
    params
    |> Admin.update_changeset(email)
    |> case do
      %Changeset{valid?: true} = changeset ->
        {:ok, changeset}

      %Changeset{errors: [email: {"Invalid format email.", _}]} ->
        {:error, :invalid_format_email}
    end
  end

  defp changeset(params) do
    case Admin.changeset(params) do
      %Changeset{errors: [password_validation: {"Differents password.", _}]} ->
        {:error, :differents_passwords}

      %Changeset{errors: [email: {"Email already in use.", _}]} ->
        {:error, :email_already_in_use}

      %Changeset{errors: [email: {"Invalid format email.", _}]} ->
        {:error, :email_format_invalid}

      %Changeset{
        errors: [password: {"Password must accountin between 4 and 10 characters.", _}]
      } ->
        {:error, :password_must_contain_between_4_e_10_characters}

      %Changeset{errors: [password_validation: {"can't be blank", [validation: :required]}]} ->
        {:error, :password_validation_necessery}

      %Changeset{errors: [password_validation: _, password: _]} ->
        {:error, :differents_passwords}

      changeset ->
        {:ok, changeset}
    end
  end
end
