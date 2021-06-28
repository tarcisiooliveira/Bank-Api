defmodule BankApiWeb.ControllerRelatorioAdministradorTest do
  use BankApiWeb.ConnCase, async: false
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian
  alias BankApi.Schemas.{Operacao, TipoConta, Conta, Usuario}

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)
    {:ok, token, _claims} = Guardian.encode_and_sign(admin)
    %TipoConta{id: id_tipo_conta} = insert(:tipo_conta, nome_tipo_conta: "Poupança")

    %Usuario{id: id_usuario1, email: email1} = insert(:usuario)
    %Usuario{id: id_usuario2, email: email2} = insert(:usuario)
    %Usuario{id: id_usuario3, email: _email3} = insert(:usuario)

    %Conta{id: conta_id_1} = insert(:conta, usuario_id: id_usuario1, tipo_conta_id: id_tipo_conta)

    %Conta{id: conta_id_2} = insert(:conta, usuario_id: id_usuario2, tipo_conta_id: id_tipo_conta)
    %Conta{id: conta_id_3} = insert(:conta, usuario_id: id_usuario3, tipo_conta_id: id_tipo_conta)

    %Operacao{id: operacao_id_saque} = insert(:operacao, nome_operacao: "Saque")
    %Operacao{id: operacao_id_pagamento} = insert(:operacao, nome_operacao: "Pagamento")

    %Operacao{id: operacao_id_transferencia} = insert(:operacao)

    insert(:transacao_saque,
      conta_origem_id: conta_id_1,
      operacao_id: operacao_id_saque,
      valor: 2_000,
      inserted_at: ~N[2021-06-14 16:50:03]
    )

    insert(:transacao_saque,
      conta_origem_id: conta_id_1,
      operacao_id: operacao_id_saque,
      valor: 1_100,
      inserted_at: ~N[2021-06-14 02:30:10]
    )

    insert(:transacao_saque,
      conta_origem_id: conta_id_1,
      operacao_id: operacao_id_saque,
      valor: 750,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    # saques usuario 1 - 3850
    insert(:transacao_saque,
      conta_origem_id: conta_id_2,
      operacao_id: operacao_id_saque,
      valor: 500,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    # saques usuario 2 - 500

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id_transferencia,
      valor: 4250,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id_transferencia,
      valor: 3250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_3,
      operacao_id: operacao_id_transferencia,
      valor: 250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id_transferencia,
      valor: 3250,
      inserted_at: ~N[2021-06-17 02:17:10]
    )

    insert(:transacao,
      conta_origem_id: conta_id_2,
      conta_destino_id: conta_id_1,
      operacao_id: operacao_id_transferencia,
      valor: 7250,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    insert(:transacao_pagamento,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_3,
      operacao_id: operacao_id_pagamento,
      valor: 100,
      inserted_at: ~N[2021-07-02 09:17:10]
    )

    insert(:transacao_pagamento,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id_pagamento,
      valor: 200,
      inserted_at: ~N[2021-07-03 09:17:10]
    )

    insert(:transacao_pagamento,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id_pagamento,
      valor: 300,
      inserted_at: ~N[2021-08-02 09:17:10]
    )

    insert(:transacao_pagamento,
      conta_origem_id: conta_id_3,
      conta_destino_id: conta_id_1,
      operacao_id: operacao_id_pagamento,
      valor: 400,
      inserted_at: ~N[2021-08-03 09:17:10]
    )

    insert(:transacao_pagamento,
      conta_origem_id: conta_id_3,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id_pagamento,
      valor: 500,
      inserted_at: ~N[2021-08-03 09:17:10]
    )

    insert(:transacao_pagamento,
      conta_origem_id: conta_id_2,
      conta_destino_id: conta_id_3,
      operacao_id: operacao_id_pagamento,
      valor: 600,
      inserted_at: ~N[2021-09-02 09:17:10]
    )

    {:ok,
     valores: %{
       email1: email1,
       email2: email2,
       conta_id_1: conta_id_1,
       conta_id_2: conta_id_2,
       conta_id_3: conta_id_3,
       operacao_id_saque: operacao_id_saque,
       operacao_id_transferencia: operacao_id_transferencia,
       token: token
     }}
  end

  describe "PAGAMENTO" do
    test "assert pagamentos - Todos os valores pagos durante todo o período", state do
      params = %{"periodo" => "todo"}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante todo o período",
               "resultado" => 2100,
               "operacao" => "Pagamento"
             } = resultado
    end

    test "assert Pagamento - Todos os valores transferidos por determinada conta.", state do
      params = %{"conta_origem_id" => state[:valores].conta_id_3}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada conta.",
               "operacao" => "Pagamento",
               "resultado" => 900
             } = resultado

      params2 = %{"conta_origem_id" => state[:valores].conta_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada conta.",
               "operacao" => "Pagamento",
               "resultado" => 600
             } = resultado2
    end

    test "assert Pagamento efetuada por uma conta e entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-07-01 00:00:01",
        "periodo_final" => "2021-07-16 23:00:01",
        "conta_origem_id" => state[:valores].conta_id_1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por determinada conta.",
               "operacao" => "Pagamento",
               "resultado" => 300
             } = resultado
    end

    test "assert Pagamento -> Todos os valores pagos entre conta x -> y entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-07-01 00:00:01",
        "periodo_final" => "2021-07-16 23:00:01",
        "conta_origem_id" => state[:valores].conta_id_1,
        "conta_destino_id" => state[:valores].conta_id_2
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período entre duas contas.",
               "operacao" => "Pagamento",
               "resultado" => 200
             } = resultado
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "conta_origem_id" => "12312312313"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique Id da Conta, Data ou Operção."
             } = resultado

      params2 = %{
        "periodo_inicial" => "2021-06-32 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params2))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique a Data ou Operção."
             } = resultado2
    end

    test "assert Pagamento de entre datas - Todos os valores transferidos durante determinado período por todos",
         state do
      params = %{
        "periodo_inicial" => "2021-08-01 00:00:01",
        "periodo_final" => "2021-09-03 00:00:01"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :pagamento, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por todas contas.",
               "operacao" => "Pagamento",
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
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante todo o período",
               "resultado" => 18250,
               "operacao" => "Transferência"
             } = resultado
    end

    test "assert Transferência - Todos os valores transferidos por determinado conta.", state do
      params = %{"conta_origem_id" => state[:valores].conta_id_1}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada conta.",
               "operacao" => "Transferência",
               "resultado" => 11000
             } = resultado

      params2 = %{"conta_origem_id" => state[:valores].conta_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada conta.",
               "operacao" => "Transferência",
               "resultado" => 7250
             } = resultado2
    end

    test "assert transferência efetuada entre contras e entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "conta_origem_id" => state[:valores].conta_id_1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por determinada conta.",
               "operacao" => "Transferência",
               "resultado" => 4250
             } = resultado
    end

    test "assert transferencia -> Todos os valores transferidos entre conta x -> y entre datas",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-17 00:00:01",
        "conta_origem_id" => state[:valores].conta_id_1,
        "conta_destino_id" => state[:valores].conta_id_2
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período entre duas contas.",
               "operacao" => "Transferência",
               "resultado" => 7500
             } = resultado
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "conta_origem_id" => "12312312313"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique Id da Conta, Data ou Operção."
             } = resultado

      params2 = %{
        "periodo_inicial" => "2021-06-32 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params2))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique a Data ou Operção."
             } = resultado2
    end

    test "assert transferência de entre datas - Todos os valores transferidos durante determinado período por todos",
         state do
      params = %{
        "periodo_inicial" => "2021-06-15 00:00:01",
        "periodo_final" => "2021-06-17 00:00:01"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :transferencia, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por todas contas.",
               "operacao" => "Transferência",
               "resultado" => 15000
             } = resultado
    end
  end

  describe "SAQUE" do
    test "assert saque - Todos os valores sacados durante todo o período", state do
      params = %{"periodo" => "todo"}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante todo o período",
               "resultado" => 4350,
               "operacao" => "Saque"
             } = resultado
    end

    test "assert saque - Todos os valores sacados por determinado email", state do
      params = %{"conta_origem_id" => state[:valores].conta_id_1}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada conta.",
               "operacao" => "Saque",
               "resultado" => 3850
             } = resultado

      params2 = %{"conta_origem_id" => state[:valores].conta_id_2}

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params2))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total realizado por determinada conta.",
               "operacao" => "Saque",
               "resultado" => 500
             } = resultado2
    end

    test "assert saque de conta entre datas - Todos os valores sacados durante determinado período por conta",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01",
        "conta_origem_id" => state[:valores].conta_id_1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por determinada conta.",
               "resultado" => 3850
             } = resultado
    end

    test "error quando passa paramentros errados",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "conta_origem_id" => 123_123_123_123
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique Id da Conta, Data ou Operção."
             } = resultado

      params2 = %{
        "periodo_inicial" => "2021-06-32 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado2 =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params2))
        |> json_response(:bad_request)

      assert %{
               "mensagem" => "Dados inválidos. Verifique a Data ou Operção."
             } = resultado2
    end

    test "assert saque de entre datas - Todos os valores sacados durante determinado período por todos",
         state do
      params = %{
        "periodo_inicial" => "2021-06-15 00:00:01",
        "periodo_final" => "2021-06-17 23:00:01"
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total durante determinado período por todas contas.",
               "resultado" => 1250
             } = resultado
    end
  end
end
