defmodule BankApiWeb.AccountView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Account
  alias Ecto.Changeset

  def render("show.json", %{
        Account: %Account{
          balance_account: balance_account,
          user_id: user_id,
          account_type_id: account_type_id
        }
      }) do
    %{
      mensagem: "Tipo Account encotrado.",
      Account: %{
        balance_account: balance_account,
        user_id: user_id,
        account_type_id: account_type_id
      }
    }
  end

  def render("create.json", %{
        Account: %{
          inserted_account: %Account{
            balance_account: balance_account,
            user_id: user_id,
            account_type_id: account_type_id
          }
        }
      }) do
    %{
      mensagem: "Account Cadastrada.",
      Account: %{
        balance_account: balance_account,
        user_id: user_id,
        account_type_id: account_type_id
      }
    }
  end

  def render("update.json", %{Account: %{update_account: %Account{id: id, balance_account: balance_account}}}) do
    %{
      mensagem: "Account Atualizada.",
      Account: %{account_ID: id, balance_account: balance_account}
    }
  end

  def render("delete.json", %{
        Account: %{deleted_account: %Account{user_id: user_id, account_type_id: account_type_id}}
      }) do
    %{
      mensagem: "Account removida.",
      Account: %{ID_User: user_id, account_type: account_type_id}
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
    %{error: "Saldo inválido, ele deve ser maior ou igual a zero."}
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
