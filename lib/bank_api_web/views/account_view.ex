defmodule BankApiWeb.AccountView do
  use BankApiWeb, :view
  alias BankApi.Accounts.Schemas.Account

  def render("show.json", %{
        account: %Account{
          balance_account: balance_account,
          user_id: user_id
        }
      }) do
    %{
      message: "Account Type found.",
      account: %{
        balance_account: balance_account,
        user_id: user_id
      }
    }
  end

  def render("create.json", %{
        account: %{
          inserted_account: %Account{
            balance_account: balance_account,
            user_id: user_id
          }
        }
      }) do
    %{
      message: "Account recorded.",
      account: %{
        balance_account: balance_account,
        user_id: user_id
      }
    }
  end

  def render(
        "error.json",
        %{error: :ammount_negative_value} = _params
      ) do
    %{error: "Balance Account should be higher or equal zero."}
  end

  def render(
        "error.json",
        %{error: error}
      ) do
    %{
      error: error
    }
  end
end
