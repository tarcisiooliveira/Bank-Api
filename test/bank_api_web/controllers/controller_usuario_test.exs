defmodule BankApiWeb.ControllerUsuarioTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.Usuario
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Modulo de teste do Controlador de Usuário
  """
  describe "SHOW" do
    test "assert show - Exibe os dados de uma usuario quando informado ID correto", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(Routes.usuarios_path(conn, :show, usuario_id))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Show",
               "usuario" => %{"email" => _email, "id" => _id, "nome" => "Tarcisio"}
             } = response
    end

    test "error show - retorna erro quando não passa  toke de autorização", %{conn: conn} do
      %Usuario{id: usuario_id} = insert(:usuario)

      response =
        conn
        |> get(Routes.usuarios_path(conn, :show, usuario_id))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error show - Exibe os dados de uma conta quando informado ID errado", %{conn: conn} do
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
    test "assert create - cria usuario quando os dados são passados corretamente", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      params = %{
        "nome" => "Tarcisio",
        "email" => "tarcisiooliveira@pm.me",
        "password" => "123456"
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(Routes.usuarios_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Usuário criado com sucesso!",
               "usuario" => %{
                 "email" => "tarcisiooliveira@pm.me",
                 "id" => _id,
                 "nome" => "Tarcisio"
               }
             } = response
    end

    test "error assert - tenta criar usuario sem token de acessor ", %{conn: conn} do
      params = %{
        "nome" => "Tarcisio",
        "email" => "tarcisiooliveira@pm.me",
        "password" => "123456"
      }

      response =
        conn
        |> post(Routes.usuarios_path(conn, :create, params))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error insert - quando já existe usuario com aquele email, retorna erro informando", %{
      conn: conn
    } do
      %Usuario{email: email} = insert(:usuario)
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      params = %{
        "email" => email,
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(Routes.usuarios_path(conn, :create, params))
        |> json_response(:unprocessable_entity)

      assert %{
               "mensagem" => "Erro",
               "email" => "Email já cadastrado"
             } = response
    end
  end

  describe "UPDATE" do
    test "cadastra usuario corretamente e depois altera email para outro email valido", %{
      conn: conn
    } do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: id} = insert(:usuario)
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.usuarios_path(conn, :update, id, params))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Usuário atualizado com sucesso!",
               "usuario" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => _id,
                 "nome" => "Tarcisio"
               }
             } = response
    end

    test "error update - tenta remover usuario sem token de acesso", %{conn: conn} do
      params = %{email: "tarcisiooliveira@protonmail.com"}
      %Usuario{id: id} = insert(:usuario)

      response =
        conn
        |> patch(Routes.usuarios_path(conn, :update, id, params))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error update - cadastra usuario corretamente e depois tenta altera email para outro email já cadastrado",
         %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: id} = insert(:usuario)
      insert(:usuario, email: "tarcisiooliveira@protonmail.com")
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.usuarios_path(conn, :update, id, params))
        |> json_response(:not_found)

      assert %{"error" => "Email já cadastrado."} = response
    end

    test "assert update - Cadastra usuario corretamente e depois altera nome", %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: id} = insert(:usuario, email: "tarcisiooliveira@protonmail.com")
      params = %{nome: "oisicraT", visivel: true}

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.usuarios_path(conn, :update, id, params))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Usuário atualizado com sucesso!",
               "usuario" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => ^id,
                 "nome" => "oisicraT"
               }
             } = response
    end
  end

  describe "DELETE" do
    test "assert delete - Retorna os dados do usuario excluido do banco e mensagem confirmando",
         %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)
      %Usuario{id: id} = insert(:usuario)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.usuarios_path(conn, :delete, id))
        |> json_response(:ok)

      assert %{
               "email" => _email,
               "id" => _id,
               "message" => "Usuario Removido",
               "nome" => "Tarcisio"
             } = response
    end

    test "error delete - tenta remover usuario sem token de acesso", %{conn: conn} do
      %Usuario{id: id = insert(:usuario)}

      response =
        conn
        |> delete(Routes.usuarios_path(conn, :delete, id))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error delete - tenta apagar usuario passando id que não existe ou já foi deletado previamente",
         %{conn: conn} do
      admin = insert(:admin)

      {:ok, token, _claims} = Guardian.encode_and_sign(admin)

      response =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.usuarios_path(conn, :delete, 100_001))
        |> json_response(:not_found)

      assert %{
               "error" => "ID inválido"
             } = response
    end
  end
end
