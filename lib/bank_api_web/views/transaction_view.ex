defmodule BankApiWeb.TransactionView do
  use BankApiWeb, :view
  alias BankApi.Transactions.Schemas.Transaction

  def render(
        "show.json",
        %{
          transaction: %Transaction{
            from_account_id: from_account_id,
            to_account_id: nil,
            value: value
          }
        }
      ) do
    %{
      message: "Transaction founded",
      Transaction: %{
        from_account_id: from_account_id,
        value: value
      }
    }
  end

  def render(
        "show.json",
        %{
          transaction: %Transaction{
            from_account_id: from_account_id,
            to_account_id: to_account_id,
            value: value
          }
        }
      ) do
    %{
      message: "Transaction founded",
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        value: value
      }
    }
  end

  def render(
        "withdraw.json",
        %{
          transaction:
            {:ok,
             %{
               create_transaction: %Transaction{
                 from_account_id: from_account_id,
                 to_account_id: nil,
                 value: value
               }
             }}
        }
      ) do
    %{
      message: "Transaction finished successfully",
      Transaction: %{
        from_account_id: from_account_id,
        value: value
      }
    }
  end

  def render(
        "transfer.json",
        %{
          transaction: %{
            create_transaction: %Transaction{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              value: value
            }
          }
        }
      ) do
    %{
      message: "Transaction finished successfully",
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        value: value
      }
    }
  end
end
