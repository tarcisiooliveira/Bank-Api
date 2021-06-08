defmodule BankApiWeb.ControllerTransacaoTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Transacao, Conta, TipoConta, Usuario}
  import BankApi.Factory

  describe "show/2" do
  end

  describe "create/2" do
    test "assert ok insert - Todos parametros estão ok, cria transacao no banco", %{conn: conn} do
      # %Usuario{id: id_usuario} = insert(:usuario)
      # %TipoConta{id: id_tipo_conta} = insert(:tipo_conta)
      # %Usuario{id: id_usuario2} = insert(:usuario, nome: "Pablo", email: "pablo@pablo.com")
      # %TipoConta{id: id_tipo_conta2} = insert(:tipo_conta)
      # %{"saldo_conta" => 100_000, "usuario_id" => id_usuario, "tipo_conta_id" => id_tipo_conta}
      # %{"bola" => "sapo"} = %{"bola" => "sapo"}

      # response =
      #   conn
      #   |> post(Routes.transacao_path(conn, :create, params))
      #   |> json_response(:created)

      # IO.inspect(response)
      # assert %{
      #          "mensagem" => "Transferência realizda com sucesso!",
      #          "transacao" => %{
      #            "email" => "tarcisiooliveira@pm.me",
      #            "id" => _id,
      #            "nome" => "Tarcisio"
      #          }
      #        } = response
    end

    # test "quando já existe transacao com aquele email, retorna erro informando", %{conn: conn} do
    #   insert(:transacao)

    #   params = %{
    #     "email" => "tarcisiooliveira@pm.me",
    #     "nome" => "Tarcisio",
    #     "password" => "123456"
    #   }

    #   response =
    #     conn
    #     |> post(Routes.transacaos_path(conn, :create, params))
    #     |> json_response(:unprocessable_entity)

    #   assert %{
    #            "mensagem" => "Erro",
    #            "email" => "Email já cadastrado"
    #          } = response
    # end
  end

  describe "delete/2" do
    # test "Retorna os dados do transacao excluido do banco e mensagem confirmando", %{
    #   conn: conn
    # } do
    #   %Transacao{id: id} = insert(:transacao)

    #   response =
    #     conn
    #     |> delete(Routes.transacaos_path(conn, :delete, id))
    #     |> json_response(:ok)

    #   assert %{
    #            "email" => "tarcisiooliveira@pm.me",
    #            "id" => ^id,
    #            "message" => "Transacao Removido",
    #            "nome" => "Tarcisio"
    #          } = response
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
    #   # %Operacao{id: id_operacao} = insert(:operacao)

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
