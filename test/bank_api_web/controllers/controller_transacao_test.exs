defmodule BankApiWeb.ControllerTransacaoTest do
  use BankApiWeb.ConnCase, async: false
  use ExUnit.Case
  alias BankApi.Schemas.{Conta, TipoConta, Usuario, Conta, Operacao, Transacao}
  alias BankApi.Repo
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    %TipoConta{id: id_tipo_conta} = insert(:tipo_conta, nome_tipo_conta: "Poupança")

    %Usuario{id: id_usuario1} = insert(:usuario)
    %Usuario{id: id_usuario2} = insert(:usuario)

    %Conta{id: conta_origem_id} =
      insert(:conta, usuario_id: id_usuario1, tipo_conta_id: id_tipo_conta)

    %Conta{id: conta_destino_id} =
      insert(:conta, usuario_id: id_usuario2, tipo_conta_id: id_tipo_conta)

    %Operacao{id: operacao_id} = insert(:operacao)

    {:ok,
     valores: %{
       conta_origem_id: conta_origem_id,
       conta_destino_id: conta_destino_id,
       operacao_id: operacao_id,
       token: token
     }}
  end

  test "assert get - Exibe os dados de um saque quando é informado parametros validos", state do
    %Operacao{id: id_operacao} = insert(:operacao, nome_operacao: "Saque")

    params = %{
      "conta_origem_id" => state[:valores].conta_origem_id,
      "operacao_id" => id_operacao,
      "valor" => 700
    }

    {:ok, %Transacao{id: id}} =
      params
      |> Transacao.changeset()
      |> BankApi.Repo.insert()

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.transacao_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Transação encotrada",
             "Transacao" => %{
               "conta_origem_id" => state[:valores].conta_origem_id,
               "operacao_id" => id_operacao,
               "valor" => 700
             }
           } == response
  end

  test "assert get - Exibe os dados de uma transferencia quando é informado parametros validos",
       state do
    %Operacao{id: id_operacao} = insert(:operacao, nome_operacao: "Saque")

    params = %{
      "conta_origem_id" => state[:valores].conta_origem_id,
      "conta_destino_id" => state[:valores].conta_destino_id,
      "operacao_id" => id_operacao,
      "valor" => 900
    }

    {:ok, %Transacao{id: id}} =
      params
      |> Transacao.changeset()
      |> BankApi.Repo.insert()

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.transacao_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Transação encotrada",
             "Transacao" => %{
               "conta_origem_id" => state[:valores].conta_origem_id,
               "conta_destino_id" => state[:valores].conta_destino_id,
               "operacao_id" => id_operacao,
               "valor" => 900
             }
           } == response
  end

  test "assert ok insert/4 - Todos parametros estão ok, cria transacao entre duas contas",
       state do
    params = %{
      "conta_origem_id" => state[:valores].conta_origem_id,
      "conta_destino_id" => state[:valores].conta_destino_id,
      "operacao_id" => state[:valores].operacao_id,
      "valor" => 600
    }

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.transacao_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Transacao" => %{
               "conta_origem_id" => state[:valores].conta_origem_id,
               "conta_destino_id" => state[:valores].conta_destino_id,
               "operacao_id" => state[:valores].operacao_id,
               "valor" => 600
             },
             "mensagem" => "Transação Realizada com Sucesso"
           } == response
  end

  test "assert ok insert - Todos parametros estão ok, usuario faz um saque", state do
    %Operacao{id: operacao_id} = insert(:operacao, nome_operacao: "Saque")

    params = %{
      "conta_origem_id" => state[:valores].conta_origem_id,
      "operacao_id" => operacao_id,
      "valor" => 1000
    }

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.transacao_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Transacao" => %{
               "conta_origem_id" => state[:valores].conta_origem_id,
               "operacao_id" => operacao_id,
               "valor" => 1000
             },
             "mensagem" => "Transação Realizada com Sucesso"
           } == response
  end

  describe "delete/1" do
    test "delete ok - remove  transação de saque cadastrada na base de dados", state do
      %Operacao{id: operacao_id} = insert(:operacao, nome_operacao: "Saque")

      params = %{
        "conta_origem_id" => state[:valores].conta_origem_id,
        "operacao_id" => operacao_id,
        "valor" => 1000
      }

      total_antes = Repo.aggregate(Transacao, :count)

      {:ok, %Transacao{id: id}} =
        params
        |> Transacao.changeset()
        |> BankApi.Repo.insert()

      total_depois = Repo.aggregate(Transacao, :count)
      assert total_antes < total_depois

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.transacao_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "Transacao" => %{
                 "conta_origem_id" => state[:valores].conta_origem_id,
                 "operacao_id" => operacao_id,
                 "valor" => 1000
               },
               "mensagem" => "Transação Removida com Sucesso"
             } == response

      total_mais_a_frente = Repo.aggregate(Transacao, :count)
      assert total_antes == total_mais_a_frente
    end

    test "delete error - tenta remover transação inexistente", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.transacao_path(state[:conn], :delete, 987_654_321))
        |> json_response(:not_found)

      assert %{
               "error" => "ID inválido"
             } = response
    end
  end
end
