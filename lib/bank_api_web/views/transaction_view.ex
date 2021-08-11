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
        "create.json",
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
        "create.json",
        %{
          transaction: %{
            create_transaction: %Transaction{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              value: value
            }
          }
        }
      )  do


    %{
      message: "Transaction finished successfully",
      Transaction: %{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        value: value
      }
    }
  end



  # def render("error.json", %{error: :balance_not_enough}) do
  #   %{error: "Balance not enough."}
  # end

  # def render("error.json", %{error: error}) do
  #   %{error: error}
  # end
end
