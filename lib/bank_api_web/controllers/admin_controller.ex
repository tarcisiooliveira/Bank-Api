defmodule BankApiWeb.AdminController do
  use BankApiWeb, :controller

  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Admins.SignIn
  alias BankApi.Admins.SignUp

  action_fallback BankApiWeb.FallbackController

  @doc """
  Create an Admin

  ## Parameters

    * `email` - String email of the admin
    * `password` - String password of the admin
    * `password_confirmation` - String password confirmation of the admin

  ## Examples
      iex> sign_up(%{"email" => "admin@admin.com", "password" => "123456", "password_confirmation" => "123456"})
      %{
        "admin" => %{
          "email" => "admin@admin.com",
          "id" => _new_id
        }
      }

      iex> sign_up(%{"email" => "test2@admin.com", "password" => "123456"})
      %{"email" => "test2@admin.com", "password" => "123456"}
  """
  def sign_up(conn, params) do
    with {:ok, %{insert_admin: %Admin{id: id, email: email}}} <- SignUp.create(params) do
      conn
      |> put_status(:ok)
      |> put_view(BankApiWeb.AdminView)
      |> render("sign_up.json", %{id: id, email: email})
    end
  end

  @doc """
  Valid an Admin, generate a token

  ## Parameters

    * `email` - String email of the admin
    * `password` - String password of the admin

  ## Examples
      iex> sign_in(%{"email" => "admin@email.com", "password" => "123456"})
     %{"token" => "token"}

      iex> sign_in(%{email: "admin@email.com", password: "1234526"})
      %{"message" => "unauthorized"}
  """

  def sign_in(conn, params) do
    with {:ok, token} <- SignIn.authenticate(params) do
      conn
      |> put_status(:ok)
      |> put_view(BankApiWeb.AdminView)
      |> render("sign_in.json", token: token)
    end
  end
end
