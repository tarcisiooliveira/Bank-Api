defmodule BankApi.Handle.Admin.HandleAdmin do
  @moduledoc """
  Used to manipulate Admin data.
  """

  alias BankApi.Multi.Admin, as: MultiAdmin
  alias BankApi.Repo
  alias BankApi.Schemas.Admin

  @doc """
  Create an Admin

  ## Parameters
    * `email` - Admin email
    * `password` - Password
    * `password_validation` - Password Validation

  ## Examples

      iex> create(%{email: email, password: password, password_validation: password_validation})
      {:ok, %{insert_admin: %Admin{}}}

      iex> update(%{id: invalid_id, account_type_name: name_account_type})
      {:error, :account_type_not_exists}}
  """
  def create(params) do
    params
    |> MultiAdmin.create()
  end

  @doc """
  Update Admin

  ## Parameters
    * `id` - ID admin
    * `email` - New admin email


  ## Examples
      iex> update(%{id: id, email: email})
      {:ok, %{update_admin: %Admin{}}}

      iex> update(%{id: invalid_id, account_type_name: name_account_type})
      {:error, :account_type_not_exists}}
  """
  def update(%{id: _id, email: _email} = params) do
    params
    |> MultiAdmin.update()
  end

  def delete(%{id: _id} = params) do
    MultiAdmin.delete(params)
  end

  def get(id) do
    id
    |> String.to_integer()
    |> fetch_admin()
    |> case do
      nil -> {:error, "Invalid ID or inexistent."}
      admin -> {:ok, admin}
    end
  end

  def fetch_admin(id) do
    Repo.get_by(Admin, id: id)
  end
end
