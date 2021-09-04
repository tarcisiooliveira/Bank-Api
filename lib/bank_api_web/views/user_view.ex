defmodule BankApiWeb.UserView do
  use BankApiWeb, :view
  alias BankApi.Users.Schemas.User
  alias BankApi.Accounts.Schemas.Account

  def render("show.json", %{user: %User{id: id, name: name, email: email}}) do
    %{
      message: "Show",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("show_account.json", %{user: %User{id: id, name: name, email: email}}) do
    %{
      message: "Show",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        user_account: %{
          insert_user: %User{id: id, name: name, email: email},
          insert_account: %Account{balance_account: balance_account}
        }
      }) do
    %{
      message: "User created sucessfuly!",
      user: %{id: id, name: name, email: email},
      account: %{balance_account: balance_account}
    }
  end

  def render(
        "sign_up.json",
        %{
          user: user,
          account: account
        }
      ) do
    %{
      user: %{
        email: user.email,
        id: user.id,
        account: %{
          id: account.id,
          balance: account.balance_account
        }
      }
    }
  end

  def render("sign_in.json", %{token: token} = _params) do
    %{token: token}
  end

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
