defmodule BankApiWeb.AccountView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Account

  def render("show.json", %{
        account: %Account{
          balance_account: balance_account,
          user_id: user_id,
          account_type_id: account_type_id
        }
      }) do
    %{
      mensagem: "Account Type found.",
      account: %{
        balance_account: balance_account,
        user_id: user_id,
        account_type_id: account_type_id
      }
    }
  end

  def render("create.json", %{
        account: %{
          inserted_account: %Account{
            balance_account: balance_account,
            user_id: user_id,
            account_type_id: account_type_id
          }
        }
      }) do
    %{
      mensagem: "Account recorded.",
      account: %{
        balance_account: balance_account,
        user_id: user_id,
        account_type_id: account_type_id
      }
    }
  end

  def render("update.json", %{
        account: %{updated_account: %Account{id: id, balance_account: balance_account}}
      }) do
    %{
      mensagem: "Account updated.",
      account: %{account_id: id, balance_account: balance_account}
    }
  end

  def render("delete.json", %{
        account: %{deleted_account: %Account{user_id: user_id, account_type_id: account_type_id}}
      }) do
    %{
      mensagem: "Account deleted.",
      account: %{user_id: user_id, account_type: account_type_id}
    }
  end

  def render("delete.json", %{error: :theres_no_account}) do
    %{
      error: "Invalid ID or inexistent."
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      error: error
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
