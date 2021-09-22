defmodule BankApi.Transaction.WithdrawTest do
  use BankApi.DataCase, async: true

  import BankApi.Factory

  alias BankApi.Accounts.Schemas.Account

  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Users.Schemas.User
  alias BankApi.Withdraw
  alias Ecto.Changeset

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
        value: "6000"
      }

      {:ok, result} = Withdraw.run(params)

      assert %{changeset_balance_account_from: %Account{balance_account: 94_000}} = result
      assert %{create_transaction: %Transaction{value: 6_000}} = result
      assert %{negative_value: false} = result
    end
  end

  describe "Run/ERROR" do
    test "ERROR withdraw invalid account" do
      params = %{
        from_account_id: Ecto.UUID.autogenerate(),
        value: "600"
      }

      assert {:error, :not_found} = Withdraw.run(params)
    end

    test "ERROR withdraw negative value", state do
      params = %{
        from_account_id: "#{state[:value].account_1}",
        value: "-600"
      }

      assert {:error, :value_zero_or_negative} = Withdraw.run(params)
    end

    test "ERROR withdraw insuficient balance ammount", state do
      params = %{
        from_account_id: "#{state[:value].account_1}",
        value: "100001"
      }

      assert {:error, %Changeset{errors: [balance_account: {"is invalid", _}]}} =
               Withdraw.run(params)
    end
  end
end
