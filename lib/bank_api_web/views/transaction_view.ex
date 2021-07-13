defmodule BankApiWeb.TransactionView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Transaction

  def render(
        "show.json",
        %{
          transaction:
            {:ok,
             %Transaction{
               from_account_id: from_account_id,
               to_account_id: nil,
               operation_id: operation_id,
               value: value
             }}
        }
      ) do
    %{
      message: "Transaction founded",
      Transaction: %{
        from_account_id: from_account_id,
        operation_id: operation_id,
        value: value
      }
    }
  end

  def render(
        "show.json",
        %{
          transaction:
            {:ok,
             %Transaction{
               from_account_id: from_account_id,
               to_account_id: to_account_id,
               operation_id: operation_id,
               value: value
             }}
        }
      ) do
    %{
      message: "Transaction founded",
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
      }
    }
  end

  def render(
        "create.json",
        %{
          transaction:
            {:ok,
             %{
               create_transaction: %Transaction{
                 from_account_id: from_account_id,
                 to_account_id: nil,
                 operation_id: operation_id,
                 value: value
               }
             }}
        }
      ) do
    %{
      message: "Transaction finished successfully",
      Transaction: %{
        from_account_id: from_account_id,
        operation_id: operation_id,
        value: value
      }
    }
  end

  def render(
        "create.json",
        %{
          transaction:
            {:ok,
             %{
               create_transaction: %Transaction{
                 from_account_id: from_account_id,
                 to_account_id: to_account_id,
                 operation_id: operation_id,
                 value: value
               }
             }}
        } = _params
      ) do
    %{
      message: "Transaction finished successfully",
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
      }
    }
  end

  def render("update.json", %{Transaction: %Transaction{value: value}}) do
    %{
      message: "Operation Updated",
      Operação: %{value: value}
    }
  end

  def render(
        "delete.json",
        %{
          Transaction: %{
            from_account_id: from_account_id,
            to_account_id: nil,
            operation_id: operation_id,
            value: value
          }
        }
      ) do
    %{
      message: "Transaction deleted successfully.",
      Transaction: %{
        from_account_id: from_account_id,
        operation_id: operation_id,
        value: value
      }
    }
  end

  def render(
        "delete.json",
        %{
          Transaction: %{
            from_account_id: from_account_id,
            to_account_id: to_account_id,
            operation_id: operation_id,
            value: value
          }
        }
      ) do
    %{
      message: "Transaction deleted successfully.2",
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
      }
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Result: "Non-existent operation.",
      message: "#{error}"
    }
  end

  def render("error.json", %{error: :transaction_not_found}) do
    %{error: "Invalid ID or inexistent."}
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
end
