defmodule BankApiWeb.Usuario.ControllerUsuarioTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.Usuario
  alias BankApi.Handle.HandleUsuario

  describe "show/2" do
    # setup %{conn: conn} do
    #   params = %{name: "Tarcisio", password: "3456789"}
    #   {:ok, trainer} = ExMon.create_trainer(params)
    #   {:ok, token, _claims} = encode_and_sign(trainer)

    #   conn = put_req_header(conn, "authorization", "Bearer #{token}")
    #   {:ok, %{conn: conn}}
    # end

    test "quando todos parametros estão ok, cria usuario no banco", %{conn: conn} do
      params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}

      response =
        conn
        |> post(Routes.usuarios_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Usuário criado com sucesso!",
               "usuario" => %{"email" => "tarcisio@ymail.com", "id" => _id, "name" => "Tarcisio"}
             } = response
    end

    test "quando já existe usuario com aquele email, retorna erro informando", %{conn: conn} do
      params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}

      HandleUsuario.create(params)

      response =
        conn
        |> get(Routes.usuarios_path(conn, :create, params))
        |> json_response(422)

      assert %{
               "mensagem" => "Erro",
               "email" => "Email já cadastrado"
               #  "informacao" => "unique",
               #  "constrain" => "usuarios_email_index"
             } = response
    end
  end

  test "Retorna os dados do usuario excluido do banco e mensagem confirmando", %{
    conn: conn
  } do
    params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}
    {:ok, %Usuario{id: id}} = HandleUsuario.create(params)

    response =
      conn
      |> delete(Routes.usuarios_path(conn, :delete, id))
      |> json_response(:ok)

    assert %{
             "email" => "tarcisio@ymail.com",
             "id" => ^id,
             "message" => "Usuario Removido",
             "name" => "Tarcisio"
           } = response
  end

  test "tenta apagar usuario passando id que não existe ou já foi deletado previamente", %{
    conn: conn
  } do
    params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}
    {:ok, %Usuario{id: id}} = HandleUsuario.create(params)
    HandleUsuario.delete(id)

    response =
      conn
      |> delete(Routes.usuarios_path(conn, :delete, id))
      |> json_response(:not_found)

    assert %{
             "error" => "ID invalido"
           } = response
  end

  test "cadastra usuario corretamente e depois altera email para outro email valido", %{
    conn: conn
  } do
    params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}
    {:ok, %Usuario{id: id}} = HandleUsuario.create(params)

    response =
      conn
      |> patch(Routes.usuarios_path(conn, :update, id, %{email: "novoemail@email.com"}))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Usuário atualizado com sucesso!",
             "usuario" => %{"email" => "novoemail@email.com", "id" => ^id, "name" => "Tarcisio"}
           } = response
  end

  test "cadastra usuario corretamente e depois altera email para outro email já cadastrado", %{
    conn: conn
  } do
    params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}
    params2 = %{"email" => "tarcisio2@ymail.com", "name" => "Tarcisio2", "password" => "123456"}
    {:ok, %Usuario{id: id}} = HandleUsuario.create(params)
    HandleUsuario.create(params2)

    response =
      conn
      |> patch(Routes.usuarios_path(conn, :update, id, %{email: "tarcisio2@ymail.com"}))
      |> json_response(:not_found)

    assert %{"error" => "Email já cadastrado."} = response
  end

  test "cadastra usuario corretamente e depois altera nome", %{
    conn: conn
  } do
    params = %{"email" => "tarcisio@ymail.com", "name" => "Tarcisio", "password" => "123456"}
    {:ok, %Usuario{id: id}} = HandleUsuario.create(params)

    response =
      conn
      |> patch(Routes.usuarios_path(conn, :update, id, %{name: "oisicraT"}))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Usuário atualizado com sucesso!",
             "usuario" => %{"email" => "tarcisio@ymail.com", "id" => ^id, "name" => "Tarcisio"}
           } = response
  end
end
