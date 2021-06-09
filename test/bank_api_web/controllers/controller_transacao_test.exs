defmodule BankApiWeb.ControllerTransacaoTest do
  use BankApiWeb.ConnCase, async: true
  use ExUnit.Case
  alias BankApi.Schemas.{Conta, TipoConta, Usuario, Conta, Operacao}
  import BankApi.Factory

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    %TipoConta{id: id_tipo_conta} = insert(:tipo_conta, nome_tipo_conta: "Poupança")

    %Usuario{id: id_usuario1, email: _email} = insert(:usuario)
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
       operacao_id: operacao_id
     }}
  end

  describe "show/2" do
  end

  describe "create" do
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
      %Operacao{id: id_operacao} = insert(:operacao, nome_operacao: "Saque")

      params = %{
        "conta_origem_id" => state[:valores].conta_origem_id,
        "operacao_id" => id_operacao,
        "valor" => 1000
      }

      response =
        state[:conn]
        |> post(Routes.transacao_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "Transacao" => %{
                 "conta_origem_id" => state[:valores].conta_origem_id,
                 "operacao_id" => id_operacao,
                 "nome_operacao" => "Saque",
                 "valor" => 1000
               },
               "mensagem" => "Transação Realizada com Sucesso"
             } == response
    end
  end

  describe "delete/2" do
    # test "Retorna os dados do transacao excluido do banco e mensagem confirmando", state do
    #   # %Transacao{id: id} = insert(:transacao)

    #   assert %{
    #            "email" => "tarcisiooliveira@pm.me",
    #            "id" => "^id",
    #            "message" => "Transacao Removido",
    #            "nome" => "Tarcisio"
    #          } = "response"
    # end

    # test "tenta apagar transacao passando id que não existe ou já foi deletado previamente", %{
    #   conn: conn
    # } do
    #   response =
    #     conn
    #     |> delete(Routes.transacaos_path(conn, :delete, 1))
    #     |> json_response(:not_found)

    #   assert %{
    #            "error" => "ID inválido"
    #          } = response
    # end
  end

  describe "update/2" do
    # test "cadastra transacao corretamente e depois altera email para outro email valido", %{
    #   conn: conn
    # } do
    #   %Transacao{id: id} = insert(:transacao)

    #   response =
    #     conn
    #     |> patch(
    #       Routes.transacaos_path(conn, :update, id, %{email: "tarcisiooliveira@protonmail.com"})
    #     )
    #     |> json_response(:ok)

    #   assert %{
    #            "mensagem" => "Usuário atualizado com sucesso!",
    #            "transacao" => %{
    #              "email" => "tarcisiooliveira@protonmail.com",
    #              "id" => ^id,
    #              "nome" => "Tarcisio"
    #            }
    #          } = response
    # end

    # test "cadastra transacao corretamente e depois altera email para outro email já cadastrado", %{
    #   conn: conn
    # } do
    #   %Transacao{id: id} = insert(:transacao)
    #   insert(:transacao, email: "tarcisiooliveira@protonmail.com")

    #   response =
    #     conn
    #     |> patch(
    #       Routes.transacaos_path(conn, :update, id, %{email: "tarcisiooliveira@protonmail.com"})
    #     )
    #     |> json_response(:not_found)

    #   assert %{"error" => "Email já cadastrado."} = response
    # end
    # test "cadastra transacao corretamente e depois altera nome", %{
    #   conn: conn
    # } do
    #   %Transacao{id: id} = insert(:transacao, email: "tarcisiooliveira@protonmail.com")

    #   response =
    #     conn
    #     |> patch(Routes.transacaos_path(conn, :update, id, %{nome: "oisicraT", visivel: true}))
    #     |> json_response(:ok)

    #   assert %{
    #            "mensagem" => "Usuário atualizado com sucesso!",
    #            "transacao" => %{
    #              "email" => "tarcisiooliveira@protonmail.com",
    #              "id" => ^id,
    #              "nome" => "oisicraT"
    #            }
    #          } = response
    # end
    # test "quando todos parametros estão ok, usuário faz um saque", %{conn: conn} do
    #   %Usuario{id: id_origem} = insert(:usuario)
    #   # %Operacao{id: operacao_id} = insert(:operacao)

    #   params = %{
    #     "conta_origem_id" => id_origem,
    #     "operacao_id" => 1,
    #     "valor" => 200_000
    #   }

    #   response =
    #     conn
    #     |> post(Routes.transacoes_path(conn, :create, params))
    #     |> json_response(:created)

    #   assert %{
    #            "mensagem" => "Usuário criado com sucesso!",
    #            "transacao" => %{
    #              "email" => "tarcisiooliveira@pm.me",
    #              "id" => _id,
    #              "nome" => "Tarcisio"
    #            }
    #          } = response
    # end
  end
end
