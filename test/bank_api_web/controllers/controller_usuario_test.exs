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
       token: token
     }}
  end

  describe "Create" do
    test "assert get", state do
      params = %{
        "nome" => "Tarcisio",
        "email" => "tarcisiooliveira@pm.me",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.usuarios_path(state[:conn], :create, params))
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

    test "quando todos parametros estão ok, cria usuario no banco", state do
      params = %{
        "email" => "tarcisiooliveira@pm.me",
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.usuarios_path(state[:conn], :create, params))
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

    test "quando já existe usuario com aquele email, retorna erro informando", state do
      %Usuario{email: email} = insert(:usuario)

      params = %{
        "email" => email,
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.usuarios_path(state[:conn], :create, params))
        |> json_response(:unprocessable_entity)

      assert %{
               "mensagem" => "Erro",
               "email" => "Email já cadastrado"
             } = response
    end
  end

  describe "delete" do
    test "Retorna os dados do usuario excluido do banco e mensagem confirmando", state do
      %Usuario{id: id, email: email} = insert(:usuario)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.usuarios_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "email" => ^email,
               "id" => ^id,
               "message" => "Usuario Removido",
               "nome" => "Tarcisio"
             } = response
    end

    test "tenta apagar usuario passando id que não existe ou já foi deletado previamente",
         state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.usuarios_path(state[:conn], :delete, 100_001))
        |> json_response(:not_found)

      assert %{
               "error" => "ID inválido"
             } = response
    end
  end

  describe "update" do
    test "cadastra usuario corretamente e depois altera email para outro email valido", state do
      %Usuario{id: id} = insert(:usuario)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(
          Routes.usuarios_path(state[:conn], :update, id, %{
            email: "tarcisiooliveira@protonmail.com"
          })
        )
        |> json_response(:ok)

      assert %{
               "mensagem" => "Usuário atualizado com sucesso!",
               "usuario" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => ^id,
                 "nome" => "Tarcisio"
               }
             } = response
    end

    test "cadastra usuario corretamente e depois altera email para outro email já cadastrado",
         state do
      %Usuario{id: id} = insert(:usuario)
      insert(:usuario, email: "tarcisiooliveira@protonmail.com")

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(
          Routes.usuarios_path(state[:conn], :update, id, %{
            email: "tarcisiooliveira@protonmail.com"
          })
        )
        |> json_response(:not_found)

      assert %{"error" => "Email já cadastrado."} = response
    end

    test "cadastra usuario corretamente e depois altera nome", state do
      %Usuario{id: id} = insert(:usuario, email: "tarcisiooliveira@protonmail.com")

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(
          Routes.usuarios_path(state[:conn], :update, id, %{nome: "oisicraT", visivel: true})
        )
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
end
