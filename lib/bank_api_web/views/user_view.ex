defmodule BankApiWeb.UserView do
  use BankApiWeb, :view

  def render("show.json", %{user: user}) do
    %{
      user: %{
        email: user.email,
        id: user.id,
        account: %{
          id: user.accounts.id,
          balance: user.accounts.balance_account
        }
      }
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
end
