defmodule BankApi.ControllerAdminTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApiWeb.Auth.Guardian
  import BankApi.Factory

  @moduledoc """
  Modulo de teste do Controlador de Admin
  """

  # setup do
  #   [conn: "Phoenix.ConnTest.build_conn()"]
  #   admin = insert(:admin)
  #   {:ok, token, _claims} = Guardian.encode_and_sign(admin)

  #   {:ok,
  #    valores: %{
  #      token: token,
  #      admin: admin
  #    }}
  # end

  describe "CREATE" do
    test "assert create admin - Cria admin passando token", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      params2 = %{
        "email" => "test2@admin.com",
        "password" => "123456",
        "password_confirmation" => "123456"
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(Routes.admin_path(conn, :create, params2))
        |> json_response(:created)

      assert %{
               "admin" => %{"email" => "test2@admin.com"},
               "mensagem" => "Administrador Cadastrado"
             } = response
    end

    test "error create admin - tenta criar admin faltando password_confirmation", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      params2 = %{
        "email" => "test2@admin.com",
        "password" => "123456"
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(Routes.admin_path(conn, :create, params2))
        |> json_response(422)

      assert %{
               "error" => "Campo Confirmação de Senha não informado",
               "mensagem" => "Administrador Não Cadastrado"
             } = response
    end

    test "error create admin - tenta criar admin sem token ", %{conn: conn} do

      params2 = %{
        "email" => "test2@admin.com",
        "password" => "123456",
        "password_confirmation" => "123456"
      }

      response =
        conn
        |> post(Routes.admin_path(conn, :create, params2))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end
  end

  describe "DELETE" do
    test "assert delete ok- remove administrador", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.admin_path(conn, :delete, admin.id))
        |> json_response(:ok)

      assert %{"email" => "tarcisio@admin.com", "mensagem" => "Administrador removido"} = response
    end

    test "error delete - tenta remover administrador inexistente", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.admin_path(conn, :delete, 789_456_123))
        |> json_response(404)

      assert %{
               "Erro" => "Administrador não removido.",
               "Resultado" => "ID Inválido ou inexistente"
             } = response
    end

    test "error delete - tenta remover administrador com token invalido", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token <> ".")
        |> delete(Routes.admin_path(conn, :delete, 789_456_123))

      assert %{resp_body: "{\"messagem\":\"invalid_token\"}", status: 401} = response
    end

    test "error delete - tenta remover administrador sem token de acesso", %{conn: conn} do
      response =
        conn
        |> delete(Routes.admin_path(conn, :delete, 789_456_123))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end
  end

  describe "UPDATE" do
    test "assert update admin - admin atualiza email", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      params = %{email: "update-email@email.com"}

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.admin_path(conn, :update, admin.id, params))
        |> json_response(:ok)

      assert %{"mensagem" => "Admininstrador Atualizado", "email" => "update-email@email.com"} =
               response
    end

    test "error update - tenta atualizar admin sem token de acesso", %{conn: conn} do
      admin = insert(:admin)
      params = %{email: "update-email@email.com"}

      response =
        conn
        |> patch(Routes.admin_path(conn, :update, admin.id, params))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error update - tenta alterar endereço de email para um já cadastrado", %{conn: conn} do
      admin = insert(:admin)
      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      params = %{email: "tarcisio@admin.com"}

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.admin_path(conn, :update, admin.id, params))
        |> json_response(:not_found)

      assert %{"error" => "Email já cadastrado."} = response
    end
  end
end
