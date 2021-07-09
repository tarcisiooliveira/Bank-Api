defmodule BankApiWeb.ControllerReportAdministradorTest do
  use BankApiWeb.ConnCase, async: false
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian
  alias BankApi.Schemas.{Operation, AccountType, Account, User}

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)
    {:ok, token, _claims} = Guardian.encode_and_sign(admin)
    %AccountType{id: id_account_type} = insert(:account_type, account_type_name: "Poupança")

    %User{id: id_User1, email: email1} = insert(:user)
    %User{id: id_User2, email: email2} = insert(:user)
    %User{id: id_User3, email: _email3} = insert(:user)

    %Account{id: account_id_1} = insert(:account, user_id: id_User1, account_type_id: id_account_type)

    %Account{id: account_id_2} = insert(:account, user_id: id_User2, account_type_id: id_account_type)
    %Account{id: account_id_3} = insert(:account, user_id: id_User3, account_type_id: id_account_type)

    %Operation{id: operation_id_withdraw} = insert(:operation, operation_name: "Withdraw")
    %Operation{id: operation_id_payment} = insert(:operation, operation_name: "Payment")

    %Operation{id: operation_id_transferencia} = insert(:operation)

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
      operation_id: operation_id_transferencia,
      value: 4250,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_transferencia,
      value: 3250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_3,
      operation_id: operation_id_transferencia,
      value: 250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      operation_id: operation_id_transferencia,
      value: 3250,
      inserted_at: ~N[2021-06-17 02:17:10]
    )

    insert(:transaction,
      from_account_id: account_id_2,
      to_account_id: account_id_1,
      operation_id: operation_id_transferencia,
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
       operation_id_transferencia: operation_id_transferencia,
       token: token
     }}
  end

  describe "PAGAMENTO" do
    test "assert payments - Todos os valores pagos durante todo o período", state do
      params = %{"periodo" => "todo"}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante todo o período",
               "resultado" => 2100,
               "Operation" => "Payment"
             } = resultado
    end

    test "assert Payment - Todos os valores transferidos por determinada Account.", state do
      params = %{"from_account_id" => state[:valores].account_id_3}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada Account.",
               "Operation" => "Payment",
               "resultado" => 900
             } = resultado

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada Account.",
               "Operation" => "Payment",
               "resultado" => 600
             } = resultado2
    end

    test "assert Payment efetuada por uma Account e entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-07-01 00:00:01",
        "periodo_final" => "2021-07-16 23:00:01",
        "from_account_id" => state[:valores].account_id_1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por determinada Account.",
               "Operation" => "Payment",
               "resultado" => 300
             } = resultado
    end

    test "assert Payment -> Todos os valores pagos entre Account x -> y entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-07-01 00:00:01",
        "periodo_final" => "2021-07-16 23:00:01",
        "from_account_id" => state[:valores].account_id_1,
        "to_account_id" => state[:valores].account_id_2
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período entre duas accounts.",
               "Operation" => "Payment",
               "resultado" => 200
             } = resultado
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "from_account_id" => "12312312313"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique Id da Account, Data ou Operção."
             } = resultado

      params2 = %{
        "periodo_inicial" => "2021-06-32 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params2))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique a Data ou Operção."
             } = resultado2
    end

    test "assert Payment de entre datas - Todos os valores transferidos durante determinado período por todos",
         state do
      params = %{
        "periodo_inicial" => "2021-08-01 00:00:01",
        "periodo_final" => "2021-09-03 00:00:01"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :payment, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por todas accounts.",
               "Operation" => "Payment",
               "resultado" => 1800
             } = resultado
    end
  end

  describe "TRANSFERENCIAS" do
    test "assert transferencia - Todos os valores transferidos durante todo o período", state do
      params = %{"periodo" => "todo"}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante todo o período",
               "resultado" => 18250,
               "Operation" => "Transfer"
             } = resultado
    end

    test "assert Transfer - Todos os valores transferidos por determinado Account.", state do
      params = %{"from_account_id" => state[:valores].account_id_1}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada Account.",
               "Operation" => "Transfer",
               "resultado" => 11000
             } = resultado

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada Account.",
               "Operation" => "Transfer",
               "resultado" => 7250
             } = resultado2
    end

    test "assert transfer efetuada entre contras e entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "from_account_id" => state[:valores].account_id_1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por determinada Account.",
               "Operation" => "Transfer",
               "resultado" => 4250
             } = resultado
    end

    test "assert transferencia -> Todos os valores transferidos entre Account x -> y entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-17 00:00:01",
        "from_account_id" => state[:valores].account_id_1,
        "to_account_id" => state[:valores].account_id_2
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período entre duas accounts.",
               "Operation" => "Transfer",
               "resultado" => 7500
             } = resultado
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "from_account_id" => "12312312313"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique Id da Account, Data ou Operção."
             } = resultado

      params2 = %{
        "periodo_inicial" => "2021-06-32 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params2))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique a Data ou Operção."
             } = resultado2
    end

    test "assert transfer de entre datas - Todos os valores transferidos durante determinado período por todos",
         state do
      params = %{
        "periodo_inicial" => "2021-06-15 00:00:01",
        "periodo_final" => "2021-06-17 00:00:01"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por todas accounts.",
               "Operation" => "Transfer",
               "resultado" => 15000
             } = resultado
    end
  end

  describe "Withdraw" do
    test "assert withdraw - Todos os valores sacados durante todo o período", state do
      params = %{"periodo" => "todo"}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante todo o período",
               "resultado" => 4350,
               "Operation" => "Withdraw"
             } = resultado
    end

    test "assert withdraw - Todos os valores sacados por determinado email", state do
      params = %{"from_account_id" => state[:valores].account_id_1}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada Account.",
               "Operation" => "Withdraw",
               "resultado" => 3850
             } = resultado

      params2 = %{"from_account_id" => state[:valores].account_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada Account.",
               "Operation" => "Withdraw",
               "resultado" => 500
             } = resultado2
    end

    test "assert withdraw de Account entre datas - Todos os valores sacados durante determinado período por Account",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01",
        "from_account_id" => state[:valores].account_id_1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por determinada Account.",
               "resultado" => 3850
             } = resultado
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "from_account_id" => 123_123_123_123
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique Id da Account, Data ou Operção."
             } = resultado

      params2 = %{
        "periodo_inicial" => "2021-06-32 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params2))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique a Data ou Operção."
             } = resultado2
    end

    test "assert withdraw de entre datas - Todos os valores sacados durante determinado período por todos",
         state do
      params = %{
        "periodo_inicial" => "2021-06-15 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.report_path(state[:conn], :withdraw, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por todas accounts.",
               "resultado" => 1250
             } = resultado
    end
  end
end
