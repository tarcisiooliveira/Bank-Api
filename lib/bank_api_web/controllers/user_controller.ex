defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller

  alias BankApi.Users.Schemas.User
  alias BankApi.Repo
  alias BankApi.User.SignIn
  alias BankApi.Users.Schemas.User
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Multi.User, as: MultiUser

  action_fallback(BankApiWeb.FallbackController)

  @doc """
  Show an User

  ## Parameters

    * `email` - String email of the user

  ## Examples
      iex> show(%{"email" => "user@email.com"})
      %{message: "Show",
        user: %{id: id, name: name, email: email}
      }

      iex> show(%{email: "user@email.com", password: "1234526"})
      %{message: "Show",
        user: %{id: id, name: name, email: email}
      }
  """

  def show(conn, _params) do
    %Plug.Conn{
      private: %{
        :guardian_default_claims => %{
          "sub" => user
        }
      }
    } = conn

    with {:ok, user} <- fetch_id(user) do
      conn
      |> put_status(:ok)
      |> render("show.json", user: user)
    end
  end

  def show_account(conn, %{"email" => email}) do
    with {:ok, user} <- fetch_email(email) do
      conn
      |> put_status(:ok)
      |> render("show_account.json", user: user)
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

      iex> create(%{email: "user@email.com", password: "1234526"})
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
      iex> sign_up(%{"email" => "test22@user.com", "password" => "123456", "password_confirmation" => "123456"})
      {
       "account": {
           "account_id": "18e9a6cc-ef35-4154-8a00-96913177b01d",
           "balance_account": 10000
       },
       "message": "User created sucessfuly!",
       "user": {
           "email": "tarcisio2@email.com",
           "user_id": "8ff5decb-e2be-4d5c-929d-6d7e6194e5a1"
       }
      }

      iex> sign_up(%{"email" => "test2@user.com", "password" => "123456", "password_confirmation" => "123s456"})
      %{"errors": {"password_confirmation": ["Passwords are different"]}}
  """

  def sign_up(conn, params) do
    with {:ok,
          %{
            insert_user: %User{id: user_id, email: email},
            insert_account: %Account{id: account_id, balance_account: balance_account}
          }} <- MultiUser.create(params) do
      conn
      |> put_status(:ok)
      |> render("sign_up.json", %{
        user_id: user_id,
        email: email,
        account_id: account_id,
        balance_account: balance_account
      })
    end
  end

  defp fetch_id(id) do
    case Repo.get_by(User, id: id) do
      nil -> {:error, :theres_no_user}
      user -> {:ok, user}
    end
  end

  defp fetch_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :theres_no_user}
      user -> {:ok, user}
    end
  end
end
