defmodule BankApiWeb.ControllerContaTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Usuario, TipoConta, Conta}
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Modulo de teste do Controlador de Conta
  """

  # setup do
  #   [conn: "Phoenix.ConnTest.build_conn()"]

  # admin = insert(:admin)

  # {:ok, token, _claims} = Guardian.encode_and_sign(admin)

  #   {:ok,
  #    valores: %{
  #      token: token
  #    }}
  # end

  describe "SHOW" do
    test "assert get - Exibe os dados de uma conta quando informado ID correto + token", %{
      conn: conn
    } do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)
      %Conta{id: conta_id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
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

    test "error show - exibe mensagem de erro quando não tem token de acesso", %{conn: conn} do
            %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)
      %Conta{id: conta_id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> get(Routes.conta_path(conn, :show, conta_id))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error get - Exibe os dados de uma conta quando informado ID errado", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(Routes.conta_path(conn, :show, 951_951))
        |> json_response(:not_found)

      assert %{"mensagem" => "ID Inválido ou inexistente"} = response
    end
  end

  describe "CREATE" do
    test "insert Conta - Cadastra Conta quando todos parametros estão OK", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      params = %{
        "saldo_conta" => 100_000,
        "usuario_id" => usuario_id,
        "tipo_conta_id" => tipo_conta_id
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
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

    test "assert ok insert Conta - Cadastra conta faltando saldo, default 100_000", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      params = %{
        "usuario_id" => usuario_id,
        "tipo_conta_id" => tipo_conta_id
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
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
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      params = %{
        "saldo_conta" => -10_000,
        "usuario_id" => usuario_id,
        "tipo_conta_id" => tipo_conta_id
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(Routes.conta_path(conn, :create, params))
        |> json_response(404)

      assert %{"error" => "Saldo inválido, ele deve ser maior ou igual a zero"} = response
    end

    test "erro insert Conta - tenta inserir usuario sem token de acesso", %{conn: conn} do

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

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end
  end

  describe "UPDATE" do
    test "assert update - atualiza saldo para valor válido maior que zero", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.conta_path(conn, :update, id, %{"saldo_conta" => 5_000}))
        |> json_response(:created)

      assert %{
               "mensagem" => "Conta Atualizada",
               "Conta" => %{"conta_ID" => _id_usuario, "saldo_conta" => 5000}
             } = response
    end

    test "assert update - atualiza saldo para valor válido igual a zero", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.conta_path(conn, :update, id, %{"saldo_conta" => 0}))
        |> json_response(:created)

      assert %{
               "mensagem" => "Conta Atualizada",
               "Conta" => %{"conta_ID" => _id_usuario, "saldo_conta" => 0}
             } = response
    end

    test "error update - tenta atualizar saldo para valor menor que zero", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.conta_path(conn, :update, id, %{"saldo_conta" => -1}))
        |> json_response(404)

      assert %{"error" => "Saldo inválido, ele deve ser maior ou igual a zero"} = response
    end

    test "error update - Tenta atualizar saldo sem token de acesso", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> patch(Routes.conta_path(conn, :update, id, %{"saldo_conta" => -1}))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end
  end

  describe "DELETE" do
    test "assert delete - Deleta conta quando ID é passado corretamente", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: usuario_id} = insert(:usuario)
      %TipoConta{id: tipo_conta_id} = insert(:tipo_conta)

      %Conta{id: id} = insert(:conta, usuario_id: usuario_id, tipo_conta_id: tipo_conta_id)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.conta_path(conn, :delete, id))
        |> json_response(:ok)

      assert %{
               "Conta" => %{"ID_Usuario" => ^usuario_id, "Tipo_Conta" => ^tipo_conta_id},
               "mensagem" => "Conta removida"
             } = response
    end

    test "error delete - Tenta deletar conta com id inexistente", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.conta_path(conn, :delete, 951_951_951))
        |> json_response(:not_found)

      assert %{"Mensagem" => "ID Inválido ou inexistente", "Resultado" => "Conta inexistente."} =
               response
    end

    test "error delete - Tenta deletar conta sem token de acesso", %{conn: conn} do
      response =
        conn
        |> delete(Routes.conta_path(conn, :delete, 951_951_951))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end
  end
end
