defmodule BankApiWeb.ControllerUsuarioTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Usuario, Admin}
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Modulo de teste do Controlador de Usuário
  """
  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    params = %{
      "email" => "test@admin.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    {:ok, admin} =
      Admin.changeset(params)
      |> BankApi.Repo.insert()

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    {:ok,
     valores: %{
       token: token,
       admin: admin
     }}
  end

  describe "SHOW" do
    test "assert show - Exibe os dados de uma usuario quando informado ID correto", state do
      %Usuario{id: usuario_id} = insert(:usuario)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.usuario_path(state[:conn], :show, usuario_id))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Show",
               "usuario" => %{"email" => _email, "id" => _id, "nome" => "Tarcisio"}
             } = response
    end

    test "error show - retorna erro quando não passa  toke de autorização", state do
      %Usuario{id: usuario_id} = insert(:usuario)

      response =
        state[:conn]
        |> get(Routes.usuario_path(state[:conn], :show, usuario_id))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error show - Exibe os dados de uma conta quando informado ID errado", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.conta_path(state[:conn], :show, 951_951))
        |> json_response(:not_found)

      assert %{"error" => "ID Inválido ou inexistente."} = response
    end
  end

  describe "CREATE" do
    test "assert create - cria usuario quando os dados são passados corretamente", state do
      params = %{
        "nome" => "Tarcisio",
        "email" => "tarcisiooliveira@protonmail.com",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.usuario_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Usuário criado com sucesso!",
               "usuario" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => _id,
                 "nome" => "Tarcisio"
               }
             } = response
    end

    test "error assert - tenta criar usuario sem token de acessor ", state do
      params = %{
        "nome" => "Tarcisio",
        "email" => "tarcisiooliveira@protonmail.com",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> post(Routes.usuario_path(state[:conn], :create, params))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error insert - quando já existe usuario com aquele email, retorna erro informando",
         state do
      %Usuario{email: email} = insert(:usuario)

      params = %{
        "email" => email,
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.usuario_path(state[:conn], :create, params))
        |> json_response(:unprocessable_entity)

      assert %{
               "mensagem" => "Erro",
               "email" => "Email já cadastrado"
             } = response
    end
  end

  describe "UPDATE" do
    test "cadastra usuario corretamente e depois altera email para outro email valido", state do
      %Usuario{id: id} = insert(:usuario)
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.usuario_path(state[:conn], :update, id, params))
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

    test "error update - tenta remover usuario sem token de acesso", state do
      %Usuario{id: id} = insert(:usuario)

      params = %{
        "email" => "email@email.com",
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> patch(Routes.usuario_path(state[:conn], :update, id, params))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error update - cadastra usuario corretamente e depois tenta altera email para outro email já cadastrado",
         state do
      %Usuario{id: id} = insert(:usuario)
      insert(:usuario, email: "tarcisiooliveira@protonmail.com")
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.usuario_path(state[:conn], :update, id, params))
        |> json_response(:not_found)

      assert %{"error" => "Email já cadastrado."} = response
    end

    test "assert update - Cadastra usuario corretamente e depois altera nome", state do
      %Usuario{id: id} = insert(:usuario, email: "tarcisiooliveira@protonmail.com")
      params = %{nome: "oisicraT", visivel: true}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.usuario_path(state[:conn], :update, id, params))
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
         state do
      %Usuario{id: id} = insert(:usuario)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.usuario_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "email" => _email,
               "id" => _id,
               "message" => "Usuario Removido",
               "nome" => "Tarcisio"
             } = response
    end

    test "error delete - tenta remover usuario sem token de acesso", state do
      %Usuario{id: id = insert(:usuario)}

      response =
        state[:conn]
        |> delete(Routes.usuario_path(state[:conn], :delete, id))

      assert %{resp_body: "{\"messagem\":\"Autorização Negada\"}", status: 401} = response
    end

    test "error delete - tenta apagar usuario passando id que não existe ou já foi deletado previamente",
         state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.usuario_path(state[:conn], :delete, 100_001))
        |> json_response(:not_found)

      assert %{
               "error" => "ID inválido"
             } = response
    end
  end
end
