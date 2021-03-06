defmodule BankApiWeb.TransactionView do
  use BankApiWeb, :view
  alias BankApi.Transactions.Schemas.Transaction

  def render(
        "withdraw.json",
        %{
          transaction: %{
            create_transaction: %Transaction{
              from_account_id: from_account_id,
              to_account_id: nil,
              value: value
            }
          }
        }
      ) do
    %{
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
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        value: value
      }
    }
  end
end
