defmodule BankApiWeb.ControllerContaTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Usuario, TipoConta, Conta}
  import BankApi.Factory

  describe "Show" do
    test "assert get - Exibe os dados de uma conta quando informado ID correto", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)
      %Conta{id: conta_id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> get(Routes.conta_path(conn, :show, conta_id))
        |> json_response(:ok)

      assert %{
               "Conta" => %{
                 "saldo_conta" => 100_000,
                 "tipo_conta_id" => ^tipo_conta_id,
                 "usuario_id" => ^usuario_id
               },
               "mensagem" => "Tipo Conta encotrado"
             } = response
    end

    test "error get - Exibe os dados de uma conta quando informado ID correto", %{conn: conn} do
      response =
        conn
        |> get(Routes.conta_path(conn, :show, 951_951))
        |> json_response(:not_found)

      assert %{"mensagem" => "ID Inválido ou inexistente"} = response
    end
  end

  describe "Create" do
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

    test "erro insert Conta - Exibe mensagem de erro quando passa saldo negativo", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      params = %{
        "saldo_conta" => -10_000,
        "usuario_id" => usuario_id,
        "tipo_conta_id" => tipo_conta_id
      }

      response =
        conn
        |> post(Routes.conta_path(conn, :create, params))
        |> json_response(404)

      assert %{"error" => "Saldo inválido, ele deve ser maior ou igual a zero"} = response
    end
  end

  describe "Update" do
    test "assert update - atualiza saldo para valor válido maior que zero", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> patch(Routes.conta_path(conn, :update, id, %{"saldo_conta" => 5_000}))
        |> json_response(:created)

      assert %{
               "mensagem" => "Conta Atualizada",
               "Conta" => %{"conta_ID" => _id_usuario, "saldo_conta" => 5000}
             } = response
    end

    test "error update - tenta atualizar saldo para valor menor que zero", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> patch(Routes.conta_path(conn, :update, id, %{"saldo_conta" => -5_000}))
        |> json_response(404)

      assert %{"error" => "Saldo inválido, ele deve ser maior ou igual a zero"} = response
    end
  end

  describe "Delete" do
    test "assert delete - Deleta conta quando ID é passado", %{
      conn: conn
    } do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> delete(Routes.conta_path(conn, :delete, id))
        |> json_response(:ok)

      assert %{
               "Conta" => %{"ID_Usuario" => ^usuario_id, "Tipo_Conta" => ^tipo_conta_id},
               "mensagem" => "Conta removida"
             } = response
    end

    test "error delete - Tenta deletar conta com id inexistente", %{
      conn: conn
    } do
      response =
        conn
        |> delete(Routes.conta_path(conn, :delete, 951_951_951))
        |> json_response(:not_found)

      assert %{"Mensagem" => "ID Inválido ou inexistente", "Resultado" => "Conta inexistente."} =
               response
    end
  end
end
