defmodule BankApi.Multi.Admin do
  @moduledoc """
    This Module valid manipulations of Admin and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Repo
  alias BankApi.Admins.Schemas.Admin

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
  def create(params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:insert_admin, fn _ ->
        Admin.changeset(params)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end
end
