defmodule BankApi.Multi.Admin do
  @moduledoc """
    This Module valid manipulations of Admin and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.Admin
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Admin, as: HandleRepoAdmin
  alias Ecto.Changeset

  def create(
        %{email: _email, password: _password, password_validation: _password_validation} =
          params
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

  def delete(%{id: _id} = params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_admin, fn _, _ ->
        case fetch_admin(params) do
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

  @spec update(%{:email => any, :id => any, optional(any) => any}) :: {:error, any} | {:ok, any}
  def update(%{id: id, email: email}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:try_admin_by_email, fn _, _ ->
        case fetch_admin(%{email: email}) do
          nil ->
            {:ok, "Invalid email."}

          _ ->
            {:error, "Email already in use."}
        end
      end)
      |> Ecto.Multi.run(:fetch_admin_account, fn _, _ ->
        case fetch_admin(%{id: id}) do
          nil ->
            {:error, "Invalid ID or inexistent."}

          admin ->
            {:ok, admin}
        end
      end)
      |> Ecto.Multi.update(:update_admin, fn %{fetch_admin_account: fetch_admin_account} ->
        fetch_admin_account
        |> Admin.update_changeset(%{email: email})
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp fetch_admin(params) do
    params
    |> HandleRepoAdmin.fetch_admin_by()
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
