defmodule BankApiWeb.TipoAccountView do
  use BankApiWeb, :view
  alias BankApi.Schemas.AccountType

  def render("show.json", %{account_type: %TipoAccount{account_type_name: account_type_name}}) do
    %{
      mensagem: "Tipo Account encotrado",
      "Tipo Account": %{account_type_name: account_type_name}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("create.json", %{account_type: %{create_account_type: %TipoAccount{account_type_name: account_type_name}}}) do
    %{
      mensagem: "Tipo Account criado com sucesso!",
      "Tipo Account": %{account_type_name: account_type_name}
    }
  end

  def render("update.json", %{
        account_type: %{update_account_type: %TipoAccount{account_type_name: account_type_name}}
      }) do
    %{
      mensagem: "Tipo Account alterado com sucesso!",
      "Tipo Account": %{account_type_name: account_type_name}
    }
  end

  def render("update.json", %{account_type: %TipoAccount{account_type_name: account_type_name}}) do
    %{
      mensagem: "Tipo Account alterado com sucesso!",
      "Tipo Account": %{account_type_name: account_type_name}
    }
  end

  def render("delete.json", %{
        account_type: %{delete_operation: %TipoAccount{account_type_name: account_type_name}}
      }) do
    %{
      mensagem: "Tipo Account removido com sucesso!",
      Nome: account_type_name
    }
  end

  def render("delete.json", %{account_type: %TipoAccount{account_type_name: account_type_name}}) do
    %{
      mensagem: "Tipo Account removido com sucesso!",
      Nome: account_type_name
    }
  end

  def render("error.json", %{error: :operation_not_exists}),
    do: %{error: "Invalid ID or inexistent."}

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
