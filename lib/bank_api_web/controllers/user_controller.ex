defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller

  alias BankApi.Multi.User, as: MultiUser
  alias BankApi.Users.Schemas.User
  alias BankApi.Repo

  action_fallback BankApiWeb.FallbackController

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- fetch(id) do
      conn
      |> put_status(:ok)
      |> render("show.json", user: user)
    end
  end

  defp fetch(id) do
    case Repo.get_by(User, id: id) do
      nil -> {:error, :theres_no_user}
      user -> {:ok, user}
    end
  end

  def sign_up_user(conn, %{
        "name" => name,
        "email" => email,
        "password" => password,
        "password_validation" => password_validation
      }) do
    params = %{
      name: name,
      email: email,
      password: password,
      password_validation: password_validation
    }

    with {:ok, user_account} <- MultiUser.create(params) do
      render(conn, "create.json", user_account: user_account)
    end
  end
end
