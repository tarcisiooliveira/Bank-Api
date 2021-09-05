defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller

  alias BankApi.User.SignIn
  alias BankApi.Users.CreateUser
  alias BankApi.Users.GetUser

  action_fallback(BankApiWeb.FallbackController)

  @doc """
  Show an User

  ## Examples
      iex> show(conn, _params)
      %{
        user: %{id: id, name: name, email: email}
      }
  """

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, user} <- GetUser.get_by_id(user.id) do
      conn
      |> put_status(:ok)
      |> render("show.json", user: user)
    end
  end

  @doc """
  Valid an User and generate a token

  ## Parameters

    * `email` - String email of the user
    * `password` - String password of the user

  ## Examples
      iex> authenticate(%{"email" => "user@email.com", "password" => "123456"})
     %{"token" => "token"}

      iex> create(%{email: "user@email.com", password: "invalid_password"})
      %{"message" => "unauthorized"}
  """
  def sign_in(conn, params) do
    with {:ok, token} <- SignIn.authenticate(params) do
      conn
      |> put_status(:ok)
      |> render("sign_in.json", token: token)
    end
  end

  @doc """
  Create an User

  ## Parameters

    * `email` - String email of the user
    * `password` - String password of the user
    * `password_confirmation` - String password confirmation of the user

  ## Examples
      iex> sign_up(%{"email" => "tarcisio@email.com", "password" => "123456", "password_confirmation" => "123456"})
      {
         "user": {
          "account": {
              "balance": 10000,
              "id": "09927826-fe6a-4b11-b17d-c63be66a962f"
          },
          "email": "tarcisio@email.com",
          "id": "47f0d312-6f8b-44e0-9808-41c414893b30"
        }
      }

      iex> sign_up(%{"email" => "test2@user.com", "password" => "123456", "password_confirmation" => "123s456"})
      %{"errors": {
        "password_confirmation": [
            "Passwords are different."
        ]
      }}

      iex> sign_up(%{"email" => "", "password" => "123456", "password_confirmation" => "123s456"})
      %{"errors": {
        "email": [
            "can't be blank"
        ]
        }
      }
  """

  def sign_up(conn, params) do
    with {:ok, %{insert_user: user, insert_account: account}} <- CreateUser.create(params) do
      conn
      |> put_status(:ok)
      |> render("sign_up.json", %{
        user: user,
        account: account
      })
    end
  end
end
