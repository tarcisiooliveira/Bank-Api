defmodule BankApi.ReportTest do
  use BankApi.DataCase, async: true

  import BankApi.Factory
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Report.HandleReport
  alias BankApi.Users.Schemas.User

  setup do
    %User{id: user_id1} = insert(:user)
    %User{id: user_id2} = insert(:user)
    %Account{id: account_1} = insert(:account, user_id: user_id1)
    %Account{id: account_2} = insert(:account, user_id: user_id2)

    insert(:transfer,
      from_account_id: account_1,
      to_account_id: account_2,
      inserted_at: NaiveDateTime.utc_now(),
      value: 100
    )

    insert(:transfer,
      from_account_id: account_1,
      to_account_id: account_2,
      inserted_at: ~N[2021-08-23 12:12:10],
      value: 110
    )

    insert(:transfer,
      from_account_id: account_2,
      to_account_id: account_1,
      inserted_at: ~N[2020-04-23 12:12:10],
      value: 120
    )

    insert(:withdraw,
      from_account_id: account_2,
      inserted_at: ~N[2021-07-23 12:12:10],
      value: 130
    )

    insert(:withdraw,
      from_account_id: account_2,
      inserted_at: ~N[2021-08-23 12:12:10],
      value: 140
    )

    insert(:withdraw,
      from_account_id: account_1,
      inserted_at: ~N[2021-04-23 12:12:10],
      value: 150
    )

    :ok
  end

  describe "Assert Report/1" do
    test "returns total of transactions in all period" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "all"})

      assert quantity_withdraw == 420
      assert quantity_transfer == 330
    end

    test "returns total of transactions today" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "today"})

      assert quantity_withdraw == 0
      assert quantity_transfer == 100
    end

    test "returns total of transactions in date" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "day", "day" => "2021-08-23"})

      assert quantity_withdraw == 140
      assert quantity_transfer == 110
    end

    test "returns total of transactions in curent month" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "month"})

      assert quantity_withdraw == 0
      assert quantity_transfer == 100
    end

    test "returns total of transactions in one month" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "month", "month" => "08"})

      assert quantity_withdraw == 140
      assert quantity_transfer == 110
    end

    test "returns total of transactions in one year" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "year", "year" => "2020"})

      assert quantity_withdraw == 0
      assert quantity_transfer == 120
    end

    test "returns total of transactions in current year" do
      {:ok, [result: %{withdraw: quantity_withdraw, transfer: quantity_transfer}]} =
        HandleReport.report(%{"period" => "year"})

      assert quantity_withdraw == 420
      assert quantity_transfer == 210
    end
  end

  describe "Error Report" do
    test "returns error when try invalid parameter all period" do
      result = HandleReport.report(%{"period" => "al"})

      assert {:error, :invalid_parameters} = result
    end

    test "returns error when try invalid parameter today" do
      result = HandleReport.report(%{"period" => "to day"})

      assert {:error, :invalid_parameters} = result
    end

    test "returns error when try invalid parameter in date" do
      assert {:error, :invalid_date} =
               HandleReport.report(%{"period" => "day", "day" => "2021-13-23"})

      assert {:error, :invalid_date} =
               HandleReport.report(%{"period" => "day", "day" => "2021-02-30"})

      assert {:error, :invalid_date} =
               HandleReport.report(%{"period" => "day", "day" => "2021-01-32"})
    end

    test "returns error when try invalid parameter curent month" do
      assert {:error, :invalid_parameters} = HandleReport.report(%{"perid" => "month"})
      assert {:error, :invalid_parameters} = HandleReport.report(%{"period" => "mnth"})
    end

    test "returns error when try invalid transactions in one month" do
      assert {:error, :invalid_date} =
               HandleReport.report(%{"period" => "month", "month" => "13"})

      assert {:error, :invalid_parameters} =
               HandleReport.report(%{"period" => "months", "month" => "12"})
    end

    test "returns error when try invalid transactions in one year" do
      assert {:error, :invalid_date} =
               HandleReport.report(%{"period" => "year", "year" => "-2020"})

      assert {:error, :invalid_parameters} =
               HandleReport.report(%{"period" => "months", "month" => "12"})
    end
  end
end
