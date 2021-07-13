defmodule BankApiWeb.AccountTypeView do
  use BankApiWeb, :view
  alias BankApi.Schemas.AccountType

  def render("show.json", %{account_type: %AccountType{account_type_name: account_type_name}}) do
    %{
      message: "Account Type found.",
      "Account Type": %{account_type_name: account_type_name}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("create.json", %{
        account_type: %{create_account_type: %AccountType{account_type_name: account_type_name}}
      }) do
    %{
      message: "Account Type created successfully!",
      "Account Type": %{account_type_name: account_type_name}
    }
  end

  def render("update.json", %{
        account_type: %{update_account_type: %AccountType{account_type_name: account_type_name}}
      }) do
    %{
      message: "Account Type updated successfully!",
      "Account Type": %{account_type_name: account_type_name}
    }
  end

  def render("update.json", %{account_type: %AccountType{account_type_name: account_type_name}}) do
    %{
      message: "Account Type updated successfully!",
      "Account Type": %{account_type_name: account_type_name}
    }
  end

  def render("delete.json", %{
        account_type: %{delete_operation: %AccountType{account_type_name: account_type_name}}
      }) do
    %{
      message: "Account Type deleted successfully!",
      Name: account_type_name
    }
  end

  def render("delete.json", %{account_type: %AccountType{account_type_name: account_type_name}}) do
    %{
      message: "Account Type deleted successfully!",
      Name: account_type_name
    }
  end

  def render("error.json", %{error: :operation_not_exists}),
    do: %{error: "Invalid ID or inexistent."}

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
