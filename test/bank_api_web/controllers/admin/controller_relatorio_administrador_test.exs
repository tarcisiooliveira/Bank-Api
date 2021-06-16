defmodule BankApiWeb.ControllerRelatorioAdministradorTest do
  use BankApiWeb.ConnCase, async: false
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian
  alias BankApi.Schemas.{Operacao, TipoConta, Conta, Usuario, Transacao}
  alias BankApi.Repo

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)
    {:ok, token, _claims} = Guardian.encode_and_sign(admin)
    %TipoConta{id: id_tipo_conta} = insert(:tipo_conta, nome_tipo_conta: "Poupança")

    %Usuario{id: id_usuario1, email: email1} = insert(:usuario)
    %Usuario{id: id_usuario2, email: email2} = insert(:usuario)
    %Usuario{id: id_usuario3, email: email3} = insert(:usuario)

    %Conta{id: conta_id_1} = insert(:conta, usuario_id: id_usuario1, tipo_conta_id: id_tipo_conta)

    %Conta{id: conta_id_2} = insert(:conta, usuario_id: id_usuario2, tipo_conta_id: id_tipo_conta)

    %Operacao{id: operacao_id} = insert(:operacao, nome_operacao: "Saque")

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id,
      valor: 2_000,
      inserted_at: ~N[2021-06-14 16:50:03]
    )

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id,
      valor: 1_100,
      inserted_at: ~N[2021-06-14 02:30:10]
    )

    insert(:transacao,
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      operacao_id: operacao_id,
      valor: 750,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    insert(:transacao,
      conta_origem_id: conta_id_2,
      conta_destino_id: conta_id_1,
      operacao_id: operacao_id,
      valor: 500,
      inserted_at: ~N[2021-06-16 02:17:10]
    )

    {:ok,
     valores: %{
       email1: email1,
       email2: email2,
       conta_id_1: conta_id_1,
       conta_id_2: conta_id_2,
       operacao_id: operacao_id,
       token: token
     }}
  end

  describe "SAQUE" do
    test "assert saque - Todos os valores sacados durante todo o período", state do
      params = %{"periodo" => "todo"}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{"mensagem" => "Total de saque durante todo o período", "resultado" => 4350} =
               resultado
    end

    test "assert saque - Todos os valores sacados por determinado email passado", state do
      params = %{"email" => state[:valores].email1}

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Total de saque realizado por determinado email",
               "resultado" => 3850
             } = resultado
    end

    test "assert saque de usuario entre datas - Todos os valores sacados durante determinado período por usuario",
         state do
      params = %{
        "periodo_inicial" => "2021-06-13 00:00:01",
        "periodo_final" => "2021-06-15 23:00:01",
        "email" => state[:valores].email1
      }

      resultado =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.relatorio_path(state[:conn], :saque, params))
        |> json_response(:created)

      assert %{
               "mensagem" =>
                 "Total de saque durante determinado período por determinado usuario.",
               "resultado" => 3850
             } = resultado
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
               "mensagem" => "Total de saque durante determinado período por todos usuários.",
               "resultado" => 1250
             } = resultado
    end
    test "error quando passa data inválida",
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
               "mensagem" => "Total de saque durante determinado período por todos usuários.",
               "resultado" => 1250
             } = resultado
    end
  end
end
