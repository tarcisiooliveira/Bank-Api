defmodule BankApiWeb.ControllerContaTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Usuario, TipoConta}
  import BankApi.Factory
  # alias BankApi.Repo

  describe "Create/2" do
    test "insert Conta - Cadastra Conta quando todos parametros estão OK", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      params = %{
        "saldo_conta" => 100_000,
        "usuario_id" => usuario_id,
        "tipo_conta_id" => tipo_conta_id
      }

      response =
        conn
        |> post(Routes.conta_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "Conta" => %{
                 "saldo_conta" => 100_000,
                 "tipo_conta_id" => _83,
                 "usuario_id" => _147
               },
               "mensagem" => "Conta Cadastrada"
             } = response
    end
    test "insert Conta - Cadastra conta faltando saldo, default 100_000", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      params = %{
        "usuario_id" => usuario_id,
        "tipo_conta_id" => tipo_conta_id
      }

      response =
        conn
        |> post(Routes.conta_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "Conta" => %{
                 "saldo_conta" => 100_000,
                 "tipo_conta_id" => _83,
                 "usuario_id" => _147
               },
               "mensagem" => "Conta Cadastrada"
             } = response
    end
  end

  #   test "quando já existe Conta com aquele email, retorna erro informando", %{conn: conn} do
  #     insert(:Conta)

  #     params = %{
  #       "email" => "tarcisiooliveira@pm.me",
  #       "nome" => "Tarcisio",
  #       "password" => "123456"
  #     }

  #     response =
  #       conn
  #       |> post(Routes.Contas_path(conn, :create, params))
  #       |> json_response(:unprocessable_entity)

  #     assert %{
  #              "mensagem" => "Erro",
  #              "email" => "Email já cadastrado"
  #            } = response
  #   end
  # end

  # test "Retorna os dados do Conta excluido do banco e mensagem confirmando", %{
  #   conn: conn
  # } do
  #   %Conta{id: id} = insert(:Conta)

  #   response =
  #     conn
  #     |> delete(Routes.Contas_path(conn, :delete, id))
  #     |> json_response(:ok)

  #   assert %{
  #            "email" => "tarcisiooliveira@pm.me",
  #            "id" => ^id,
  #            "message" => "Conta Removido",
  #            "nome" => "Tarcisio"
  #          } = response
  # end

  # test "tenta apagar Conta passando id que não existe ou já foi deletado previamente", %{
  #   conn: conn
  # } do
  #   response =
  #     conn
  #     |> delete(Routes.Contas_path(conn, :delete, 1))
  #     |> json_response(:not_found)

  #   assert %{
  #            "error" => "ID inválido"
  #          } = response
  # end

  # test "cadastra Conta corretamente e depois altera email para outro email valido", %{
  #   conn: conn
  # } do
  #   %Conta{id: id} = insert(:Conta)

  #   response =
  #     conn
  #     |> patch(
  #       Routes.Contas_path(conn, :update, id, %{email: "tarcisiooliveira@protonmail.com"})
  #     )
  #     |> json_response(:ok)

  #   assert %{
  #            "mensagem" => "Usuário atualizado com sucesso!",
  #            "Conta" => %{
  #              "email" => "tarcisiooliveira@protonmail.com",
  #              "id" => ^id,
  #              "nome" => "Tarcisio"
  #            }
  #          } = response
  # end

  # test "cadastra Conta corretamente e depois altera email para outro email já cadastrado", %{
  #   conn: conn
  # } do
  #   %Conta{id: id} = insert(:Conta)
  #   insert(:Conta, email: "tarcisiooliveira@protonmail.com")

  #   response =
  #     conn
  #     |> patch(
  #       Routes.Contas_path(conn, :update, id, %{email: "tarcisiooliveira@protonmail.com"})
  #     )
  #     |> json_response(:not_found)

  #   assert %{"error" => "Email já cadastrado."} = response
  # end

  # test "cadastra Conta corretamente e depois altera nome", %{
  #   conn: conn
  # } do
  #   %Conta{id: id} = insert(:Conta, email: "tarcisiooliveira@protonmail.com")

  #   response =
  #     conn
  #     |> patch(Routes.Contas_path(conn, :update, id, %{nome: "oisicraT", visivel: true}))
  #     |> json_response(:ok)

  #   assert %{
  #            "mensagem" => "Usuário atualizado com sucesso!",
  #            "Conta" => %{
  #              "email" => "tarcisiooliveira@protonmail.com",
  #              "id" => ^id,
  #              "nome" => "oisicraT"
  #            }
  #          } = response
  # end
end
