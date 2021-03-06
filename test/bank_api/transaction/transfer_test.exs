defmodule BankApi.Transaction.TransferTest do
  use BankApi.DataCase, async: false

  import BankApi.Factory
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Transactions.Schemas.Transaction

  alias BankApi.Users.Schemas.User

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
    test "assert insert transfer", state do
      params = %{
        from_account_id: "#{state[:value].account_1}",
        to_account_id: "#{state[:value].account_2}",
        value: "6000"
      }

      {:ok, result} = BankApi.Transfer.run(params)

      assert %{changeset_balance_account_from: %Account{balance_account: 94_000}} = result
      assert %{create_transaction: %Transaction{value: 6_000}} = result
      assert %{changeset_balance_account_to: %Account{balance_account: 106_000}} = result
      assert %{same_account: false} = result
      assert %{validate_balance_enought: :ammount_enought} = result
    end
  end

  describe "Run/ERROR" do
    test "ERROR transfer to the same account", state do
      params = %{
        from_account_id: "#{state[:value].account_1}",
        to_account_id: "#{state[:value].account_1}",
        value: "600"
      }

      assert {:error, :transfer_to_the_same_account} = BankApi.Transfer.run(params)
    end

    test "ERROR transfer negative value", state do
      params = %{
        from_account_id: "#{state[:value].account_1}",
        to_account_id: "#{state[:value].account_2}",
        value: "-600"
      }

      assert {:error, :value_zero_or_negative} = BankApi.Transfer.run(params)
    end

    test "ERROR insuficient balance ammount", state do
      params = %{
        from_account_id: "#{state[:value].account_1}",
        to_account_id: "#{state[:value].account_2}",
        value: "100001"
      }

      assert {:error, :insuficient_ammount} = BankApi.Transfer.run(params)
    end
  end
end
