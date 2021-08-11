defmodule BankApiWeb.UserSignController do
  use BankApiWeb, :controller

  alias BankApiWeb.Auth.GuardianUser
  alias BankApi.Users.Schemas.User
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Multi.User, as: MultiUser

  action_fallback BankApiWeb.FallbackController

  def sign_in_user(conn, params) do
    with {:ok, token} <- GuardianUser.authenticate(params) do
      conn
      |> put_status(:ok)
      |> render("sign_in_user.json", token: token)
    end
  end

  def sign_up_user(
        conn,
        %{
          "name" => name,
          "email" => email,
          "password" => password,
          "password_validation" => password_validation
        }
      ) do
    user = %{
      name: name,
      email: email,
      password: password,
      password_validation: password_validation
    }

    with {:ok,
          %{
            insert_user: %User{id: user_id, email: email},
            insert_account: %Account{id: account_id, balance_account: balance_account}
          }} <- MultiUser.create(user) do
      conn
      |> put_status(:ok)
      |> put_view(BankApiWeb.UserSignView)
      |> render("sign_up.json", %{
        user_id: user_id,
        email: email,
        account_id: account_id,
        balance_account: balance_account
      })
    end
  end

  def sign_up_user(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render("error_message.json", %{
      message: "Invalid parameters"
    })
  end
end
