defmodule BankApi.Transaction.WithdrawTest do
  use BankApi.DataCase, async: true

  import BankApi.Factory
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Report.HandleReport
  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Users.Schemas.User
  alias BankApi.Withdraw

  setup do
    %User{id: user_id1} = insert(:user)
    %User{id: user_id2} = insert(:user)
    %Account{id: account_1} = insert(:account, user_id: user_id1)
    %Account{id: account_2} = insert(:account, user_id: user_id2)

    {:ok,
     value: %{
       user_1: user_id1,
       user_2: user_id2,
       account_1: account_1,
       account_2: account_2
     }}
  end

  describe "Run assert/1" do
    test "assert withdraw", state do
      params = %{
        from_account_id: "#{state[:value].account_2}",
        value: "600"
      }

      {:ok, result} = Withdraw.run(params)

      assert %{changeset_balance_account_from: %Account{balance_account: 9400}} = result
      assert %{create_transaction: %Transaction{value: 600}} = result
      assert %{changeset_balance_account_to: %Account{balance_account: 10600}} = result
      assert %{same_account: false} = result
      assert %{validate_balance_enought: :ammount_enought} = result
    end
  end

  # describe "Run/ERROR" do
  #   test "ERROR transfer to the same account", state do
  #     params = %{
  #       from_account_id: "#{state[:value].account_1}",
  #       value: "600"
  #     }

  #     assert {:error, :transfer_to_the_same_account} = BankApi.Transfer.run(params)
  #   end

  #   test "ERROR transfer negative value", state do
  #     params = %{
  #       from_account_id: "#{state[:value].account_1}",
  #       to_account_id: "#{state[:value].account_2}",
  #       value: "-600"
  #     }

  #     assert {:error, :value_zero_or_negative} = BankApi.Transfer.run(params)
  #   end

  #   test "ERROR insuficient balance ammount", state do
  #     params = %{
  #       from_account_id: "#{state[:value].account_1}",
  #       to_account_id: "#{state[:value].account_2}",
  #       value: "10001"
  #     }

  #     assert {:error, :insuficient_ammount} = BankApi.Transfer.run(params)
  #   end
  # end
end
