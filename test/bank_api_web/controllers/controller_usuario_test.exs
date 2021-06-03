defmodule BankApiWeb.ControllerUsuarioTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.Usuario
  import BankApi.Factory

  describe "show/2" do
    # setup do
    #   insert(:usuario)
    #   :ok
    # end

    test "quando todos parametros estão ok, cria usuario no banco", %{conn: conn} do
      params = %{
        "email" => "tarcisiooliveira@pm.me",
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        conn
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

    test "quando já existe usuario com aquele email, retorna erro informando", %{conn: conn} do
      insert(:usuario)

      params = %{
        "email" => "tarcisiooliveira@pm.me",
        "nome" => "Tarcisio",
        "password" => "123456"
      }

      response =
        conn
        |> post(Routes.usuarios_path(conn, :create, params))
        |> json_response(:unprocessable_entity)

      assert %{
               "mensagem" => "Erro",
               "email" => "Email já cadastrado"
             } = response
    end
  end

  test "Retorna os dados do usuario excluido do banco e mensagem confirmando", %{
    conn: conn
  } do
    %Usuario{id: id} = insert(:usuario)

    response =
      conn
      |> delete(Routes.usuarios_path(conn, :delete, id))
      |> json_response(:ok)

    assert %{
             "email" => "tarcisiooliveira@pm.me",
             "id" => ^id,
             "message" => "Usuario Removido",
             "nome" => "Tarcisio"
           } = response
  end

  test "tenta apagar usuario passando id que não existe ou já foi deletado previamente", %{
    conn: conn
  } do
    response =
      conn
      |> delete(Routes.usuarios_path(conn, :delete, 1))
      |> json_response(:not_found)

    assert %{
             "error" => "ID inválido"
           } = response
  end

  test "cadastra usuario corretamente e depois altera email para outro email valido", %{
    conn: conn
  } do
    %Usuario{id: id} = insert(:usuario)

    response =
      conn
      |> patch(
        Routes.usuarios_path(conn, :update, id, %{email: "tarcisiooliveira@protonmail.com"})
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

  test "cadastra usuario corretamente e depois altera email para outro email já cadastrado", %{
    conn: conn
  } do
    %Usuario{id: id} = insert(:usuario)
    insert(:usuario, email: "tarcisiooliveira@protonmail.com")

    response =
      conn
      |> patch(
        Routes.usuarios_path(conn, :update, id, %{email: "tarcisiooliveira@protonmail.com"})
      )
      |> json_response(:not_found)

    assert %{"error" => "Email já cadastrado."} = response
  end

  test "cadastra usuario corretamente e depois altera nome", %{
    conn: conn
  } do
    %Usuario{id: id} = insert(:usuario, email: "tarcisiooliveira@protonmail.com")

    response =
      conn
      |> patch(Routes.usuarios_path(conn, :update, id, %{nome: "oisicraT", visivel: true}))
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
