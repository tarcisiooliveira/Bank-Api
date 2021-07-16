defmodule BankApiWeb.ControllerReportAdminTest do
  @moduledoc """
  Module test Report Controller
  """

  use BankApiWeb.ConnCase, async: false

  import BankApi.Factory

  alias BankApiWeb.Auth.Guardian
  alias BankApi.Schemas.{Operation, AccountType, Account, User}

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)
    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    %AccountType{id: id_account_type} =
      insert(:account_type, account_type_name: "Savings Account")

    %User{id: user_id1, email: email1} = insert(:user)
    %User{id: user_id2, email: email2} = insert(:user)
    %User{id: user_id3, email: _email3} = insert(:user)

    %Account{id: account_id_1} =
      insert(:account, user_id: user_id1, account_type_id: id_account_type)

    %Account{id: account_id_2} =
      insert(:account, user_id: user_id2, account_type_id: id_account_type)

    %Account{id: account_id_3} =
      insert(:account, user_id: user_id3, account_type_id: id_account_type)

    %Operation{id: operation_id_withdraw} = insert(:operation, operation_name: "Withdraw")
    %Operation{id: operation_id_payment} = insert(:operation, operation_name: "Payment")

    %Operation{id: operation_id_transfer} = insert(:operation)

    insert(:withdraw_transaction,
      from_account_id: account_id_1,
      operation_id: operation_id_withdraw,
      value: 2_000,
      inserted_at: NaiveDateTime.utc_now()
    )

    insert(:withdraw_transaction,
      from_account_id: account_id_1,
      operation_id: operation_id_withdraw,
      value: 2_000,
      inserted_at: ~N[2021-06-14 16:50:03]
    )

    insert(:withdraw_transaction,
      from_account_id: account_id_1,
      operation_id: operation_id_withdraw,
      value: 1_100,
      inserted_at: ~N[2021-06-14 02:30:10]
    )

    insert(:withdraw_transaction,
      from_account_id: account_id_1,
      operation_id: operation_id_withdraw,
      value: 750,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    # withdraws User 1 - 3850
    insert(:withdraw_transaction,
      from_account_id: account_id_2,
      operation_id: operation_id_withdraw,
      value: 500,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    # withdraws User 2 - 500
    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_transfer,
      value: 4_250,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_transfer,
      value: 3250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_3,
      operation_id: operation_id_transfer,
      value: 250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_transfer,
      value: 3250,
      inserted_at: ~N[2021-06-17 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_2,
      to_account_id: account_id_1,
      operation_id: operation_id_transfer,
      value: 7250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transaction_payment,
      from_account_id: account_id_1,
      to_account_id: account_id_3,
      operation_id: operation_id_payment,
      value: 100,
      inserted_at: ~N[2021-07-02 09:17:10]
    )

    insert(:transaction_payment,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_payment,
      value: 200,
      inserted_at: ~N[2021-07-03 09:17:10]
    )

    insert(:transaction_payment,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_payment,
      value: 300,
      inserted_at: ~N[2021-08-02 09:17:10]
    )

    insert(:transaction_payment,
      from_account_id: account_id_3,
      to_account_id: account_id_1,
      operation_id: operation_id_payment,
      value: 400,
      inserted_at: ~N[2021-08-03 09:17:10]
    )

    insert(:transaction_payment,
      from_account_id: account_id_3,
      to_account_id: account_id_2,
      operation_id: operation_id_payment,
      value: 500,
      inserted_at: ~N[2021-08-03 09:17:10]
    )

    insert(:transaction_payment,
      from_account_id: account_id_2,
      to_account_id: account_id_3,
      operation_id: operation_id_payment,
      value: 600,
      inserted_at: ~N[2021-09-02 09:17:10]
    )

    {:ok,
     valores: %{
       email1: email1,
       email2: email2,
       account_id_1: account_id_1,
       account_id_2: account_id_2,
       account_id_3: account_id_3,
       operation_id_withdraw: operation_id_withdraw,
       operation_id_transfer: operation_id_transfer,
       token: token
     }}
  end

  describe "all" do
    test "return result of all value transferred", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total moved for the entire period by all operations.",
               "result" => 26_700
             } = result
    end

    test "return result of all value transferred in curent day seted operation", state do
      params = %{"operation" => "Withdraw", "period" => "today"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in current day by operation.",
               "operation" => "Withdraw",
               "result" => 2_000
             } = result
    end

    test "result sum value in all opertions in determineted day", state do
      params = %{"period" => "day", "day" => "2021-06-14"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in seted day by all operations.",
               "result" => 3_100
             } = result
    end

    test "return result of all value transferred in curent day by all operation", state do
      params = %{"period" => "today"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in current day by all operation.",
               "result" => 2_000
             } = result
    end

    test "return result of all value transferred in curent year by operation", state do
      params = %{"operation" => "Withdraw", "period" => "year", "year" => 2021}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in current year by operations.",
               "operation" => "Withdraw",
               "result" => 6_350
             } = result
    end

    test "return result of all value transferred in curent year by all operation", state do
      params = %{"period" => "year"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in current year by all operations.",
               "result" => 26_700
             } = result
    end

    test "return result of all value transferred in curent month by operation", state do
      params = %{"operation" => "Withdraw", "period" => "month", "month" => 7}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in current month by operation.",
               "operation" => "Withdraw",
               "result" => _2_000
             } = result
    end

    test "return result of all value transferred in curent month by all operation", state do
      params = %{"period" => "month", "month" => 7}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in seted month by all operations.",
               "result" => 2_300
             } = result
    end
  end

  describe "Payment" do
    test "assert payments - return result of all value trasactioneted", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "message" => "Total for the entire period by operation.",
               "result" => 2_100,
               "operation" => "Payment"
             } = result
    end

    test "assert Payment - alls os valores transferidos por determinada Account.", state do
      params = %{"from_account_id" => state[:valores].account_id_3}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "message" => "Total for determineted operation by determineted Account.",
               "operation" => "Payment",
               "result" => 900
             } = result

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params2))
        |> json_response(:created)

      assert %{
               "message" => "Total for determineted operation by determineted Account.",
               "operation" => "Payment",
               "result" => 600
             } = resultado2
    end

    test "assert Payment by Account between dates",
         state do
      params = %{
        "initial_date" => "2021-07-01 00:00:01",
        "final_date" => "2021-07-16 23:00:01",
        "from_account_id" => state[:valores].account_id_1
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period for determineted Account.",
               "operation" => "Payment",
               "result" => 300
             } = result
    end

    test "assert Payment -> alls os valores pagos entre Account x -> y entre datas",
         state do
      params = %{
        "initial_date" => "2021-07-01 00:00:01",
        "final_date" => "2021-07-16 23:00:01",
        "from_account_id" => state[:valores].account_id_1,
        "to_account_id" => state[:valores].account_id_2
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period for determineted between tow Accounts.",
               "operation" => "Payment",
               "result" => 200
             } = result
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "initial_date" => "2021-06-13 00:00:01",
        "final_date" => "2021-06-15 23:00:01",
        "from_account_id" => "12312312313"
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:bad_request)

      assert %{
               "message" => "Invalid data. Verify Account ID, Date or Operation."
             } = result

      params2 = %{
        "initial_date" => "2021-06-32 00:00:01",
        "final_date" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params2))
        |> json_response(:bad_request)

      assert %{
               "message" => "Invalid data. Verify Date or Operation."
             } = resultado2
    end

    test "assert Payment de entre datas - alls os valores transferidos durante determinado período por alls",
         state do
      params = %{
        "initial_date" => "2021-08-01 00:00:01",
        "final_date" => "2021-09-03 00:00:01"
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period between all Accounts.",
               "operation" => "Payment",
               "result" => 1800
             } = result
    end
  end

  describe "TRASNFERS" do
    test "assert transfer - all values transfered in all peiord", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :report, params))
        |> json_response(:created)

      assert %{
               "message" => "Total moved for the entire period by all operations.",
               "result" => 26_700
             } = result
    end

    test "assert Transfer - Total trasfered by determineted Account.", state do
      params = %{"from_account_id" => state[:valores].account_id_1}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:created)

      assert %{
               "message" => "Total for determineted operation by determineted Account.",
               "operation" => "Transfer",
               "result" => 11_000
             } = result

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params2))
        |> json_response(:created)

      assert %{
               "message" => "Total for determineted operation by determineted Account.",
               "operation" => "Transfer",
               "result" => 7250
             } = resultado2
    end

    test "assert transfer between account and dates",
         state do
      params = %{
        "initial_date" => "2021-06-13 00:00:01",
        "final_date" => "2021-06-15 23:00:01",
        "from_account_id" => state[:valores].account_id_1
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period for determineted Account.",
               "operation" => "Transfer",
               "result" => 4250
             } = result
    end

    test "assert transfer -> alls values transfereds form X TO Y between dates",
         state do
      params = %{
        "initial_date" => "2021-06-13 00:00:01",
        "final_date" => "2021-06-17 00:00:01",
        "from_account_id" => state[:valores].account_id_1,
        "to_account_id" => state[:valores].account_id_2
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period for determineted between tow Accounts.",
               "operation" => "Transfer",
               "result" => 7_500
             } = result
    end

    test "error when sent invalid parameters",
         state do
      params = %{
        "initial_date" => "2021-06-13 00:00:01",
        "final_date" => "2021-06-15 23:00:01",
        "from_account_id" => "12312312313"
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:bad_request)

      assert %{
               "message" => "Invalid data. Verify Account ID, Date or Operation."
             } = result

      params2 = %{
        "initial_date" => "2021-06-32 00:00:01",
        "final_date" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params2))
        |> json_response(:bad_request)

      assert %{
               "message" => "Invalid data. Verify Date or Operation."
             } = resultado2
    end

    test "assert transfer between dates- all values transfered for all accounts all the time",
         state do
      params = %{
        "initial_date" => "2021-06-15 00:00:01",
        "final_date" => "2021-06-17 00:00:01"
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period between all Accounts.",
               "operation" => "Transfer",
               "result" => 15_000
             } = result
    end
  end

  describe "Withdraw" do
    test "assert withdraw - all values withdraw in all period by all accounts", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "message" => "Total for the entire period by operation.",
               "result" => 6_350,
               "operation" => "Withdraw"
             } = result
    end

    test "assert withdraw - all values withdraw in all period by account", state do
      params = %{"from_account_id" => state[:valores].account_id_1}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "message" => "Total for determineted operation by determineted Account.",
               "operation" => "Withdraw",
               "result" => 5850
             } = result

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params2))
        |> json_response(:created)

      assert %{
               "message" => "Total for determineted operation by determineted Account.",
               "operation" => "Withdraw",
               "result" => 500
             } = resultado2
    end

    test "assert withdraw from Account between dates - alls values withdraw in determineted period for Account",
         state do
      params = %{
        "initial_date" => "2021-06-13 00:00:01",
        "final_date" => "2021-06-17 23:00:01",
        "from_account_id" => state[:valores].account_id_1
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period for determineted Account.",
               "result" => 3_850
             } = result
    end

    test "error when send invalid parameters",
         state do
      params = %{
        "initial_date" => "2021-06-13 00:00:01",
        "final_date" => "2021-06-15 23:00:01",
        "from_account_id" => 123_123_123_123
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:bad_request)

      assert %{
               "message" => "Invalid data. Verify Account ID, Date or Operation."
             } = result

      params2 = %{
        "initial_date" => "2021-06-32 00:00:01",
        "final_date" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params2))
        |> json_response(:bad_request)

      assert %{
               "message" => "Invalid data. Verify Date or Operation."
             } = resultado2
    end

    test "assert withdraw between dates - all values withdraw between period",
         state do
      params = %{
        "initial_date" => "2021-06-15 00:00:01",
        "final_date" => "2021-06-17 23:00:01"
      }

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "message" => "Total in determineted period between all Accounts.",
               "result" => 1250
             } = result
    end
  end
end
