defmodule BankApiWeb.ControllerReportAdminTest do
  use BankApiWeb.ConnCase, async: true
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian
  alias BankApi.Schemas.{Operation, AccountType, Account, User}

  @moduledoc """
  Module test Report Controller
  """
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
      value: 4250,
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

  describe "PAGAMENTO" do
    test "assert payments - alls os valores pagos durante all o período", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total for the entire period.",
               "result" => 2100,
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
               "mensagem" => "Total trasfered by determineted Account.",
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
               "mensagem" => "Total trasfered by determineted Account.",
               "operation" => "Payment",
               "result" => 600
             } = resultado2
    end

    test "assert Payment efetuada por uma Account e entre datas",
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
               "mensagem" => "Total in determineted period for determineted Account.",
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
               "mensagem" =>
                 "Total in determineted period for determineted between tow Accounts.",
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
               "mensagem" => "Invalid data. Verify Account ID, Date or Operation."
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
               "mensagem" => "Invalid data. Verify Date or Operation."
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
               "mensagem" => "Total in determineted period between all Accounts.",
               "operation" => "Payment",
               "result" => 1800
             } = result
    end
  end

  describe "TRASNFERSS" do
    test "assert transfer - alls os valores transferidos durante all o período", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total for the entire period.",
               "result" => 18_250,
               "operation" => "Transfer"
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
               "mensagem" => "Total trasfered by determineted Account.",
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
               "mensagem" => "Total trasfered by determineted Account.",
               "operation" => "Transfer",
               "result" => 7250
             } = resultado2
    end

    test "assert transfer efetuada entre contras e entre datas",
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
               "mensagem" => "Total in determineted period for determineted Account.",
               "operation" => "Transfer",
               "result" => 4250
             } = result
    end

    test "assert transfer -> alls os valores transferidos entre Account x -> y entre datas",
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
               "mensagem" =>
                 "Total in determineted period for determineted between tow Accounts.",
               "operation" => "Transfer",
               "result" => 7500
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
        |> post(Routes.report_path(state[:conn], :transfer, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Invalid data. Verify Account ID, Date or Operation."
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
               "mensagem" => "Invalid data. Verify Date or Operation."
             } = resultado2
    end

    test "assert transfer de entre datas - alls os valores transferidos durante determinado período por alls",
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
               "mensagem" => "Total in determineted period between all Accounts.",
               "operation" => "Transfer",
               "result" => 15_000
             } = result
    end
  end

  describe "Withdraw" do
    test "assert withdraw - alls os valores sacados durante all o período", state do
      params = %{"period" => "all"}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total for the entire period.",
               "result" => 4350,
               "operation" => "Withdraw"
             } = result
    end

    test "assert withdraw - alls os valores sacados por determinado email", state do
      params = %{"from_account_id" => state[:valores].account_id_1}

      result =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total trasfered by determineted Account.",
               "operation" => "Withdraw",
               "result" => 3850
             } = result

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total trasfered by determineted Account.",
               "operation" => "Withdraw",
               "result" => 500
             } = resultado2
    end

    test "assert withdraw de Account entre datas - alls os valores sacados durante determinado período por Account",
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
               "mensagem" => "Total in determineted period for determineted Account.",
               "result" => 3850
             } = result
    end

    test "error quando passa paramentros errados",
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
               "mensagem" => "Invalid data. Verify Account ID, Date or Operation."
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
               "mensagem" => "Invalid data. Verify Date or Operation."
             } = resultado2
    end

    test "assert withdraw de entre datas - alls os valores sacados durante determinado período por alls",
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
               "mensagem" => "Total in determineted period between all Accounts.",
               "result" => 1250
             } = result
    end
  end
end
