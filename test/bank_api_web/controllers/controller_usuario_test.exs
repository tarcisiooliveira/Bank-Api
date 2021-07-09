defmodule BankApiWeb.ControllerUserTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{User, Admin}
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
    test "assert show - Exibe os dados de uma User quando informado ID correto", state do
      %User{id: user_id} = insert(:User)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.User_path(state[:conn], :show, user_id))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Show",
               "User" => %{"email" => _email, "id" => _id, "name" => "Tarcisio"}
             } = response
    end

    test "error show - retorna erro quando não passa  toke de autorização", state do
      %User{id: user_id} = insert(:User)

      response =
        state[:conn]
        |> get(Routes.User_path(state[:conn], :show, user_id))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error show - Exibe os dados de uma Account quando informado ID errado", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.User_path(state[:conn], :show, 951_951))
        |> json_response(:not_found)

      assert %{"error" => "Invalid ID or inexistent."} = response
    end
  end

  describe "CREATE" do
    test "assert create - cria User quando os dados são passados corretamente", state do
      params = %{
        "name" => "Tarcisio",
        "email" => "tarcisiooliveira@protonmail.com",
        "password" => "123456",
        "password_validation" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.User_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Usuário criado com sucesso!",
               "User" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => _id,
                 "name" => "Tarcisio"
               }
             } = response
    end

    test "error assert - tenta criar User sem token de acessor ", state do
      params = %{
        "name" => "Tarcisio",
        "email" => "tarcisiooliveira@protonmail.com",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> post(Routes.User_path(state[:conn], :create, params))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error insert - quando já existe User com aquele email, retorna erro informando",
         state do
      %User{email: email} = insert(:User)

      params = %{
        "email" => email,
        "name" => "Tarcisio2",
        "password" => "123456",
        "password_validation" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.User_path(state[:conn], :create, params))
        |> json_response(:unprocessable_entity)

      assert %{
               "message" => "Email já cadastrado."
             } = response
    end
  end

  describe "UPDATE" do
    test "cadastra User corretamente e depois altera email para outro email valido", state do
      %User{id: id} = insert(:User)
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.User_path(state[:conn], :update, id, params))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Usuário atualizado com sucesso!",
               "User" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => _id,
                 "name" => "Tarcisio"
               }
             } = response
    end

    test "error update - tenta remover User sem token de acesso", state do
      %User{id: id} = insert(:User)

      params = %{
        "email" => "email@email.com",
        "name" => "Tarcisio",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> patch(Routes.User_path(state[:conn], :update, id, params))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error update - cadastra User corretamente e depois tenta altera email para outro email já cadastrado",
         state do
      %User{id: id} = insert(:User)
      insert(:User, email: "tarcisiooliveira@protonmail.com")
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.User_path(state[:conn], :update, id, params))
        |> json_response(:not_found)

      assert %{"error" => "Email já cadastrado."} = response
    end

    test "assert update - Cadastra User corretamente e depois altera name", state do
      %User{id: id} = insert(:User, email: "tarcisiooliveira@protonmail.com")
      params = %{name: "oisicraT"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.User_path(state[:conn], :update, id, params))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Usuário atualizado com sucesso!",
               "User" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => ^id,
                 "name" => "oisicraT"
               }
             } = response
    end
  end

  describe "DELETE" do
    test "assert delete - Retorna os dados do User excluido do banco e mensagem confirmando",
         state do
      %User{id: id} = insert(:User)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.User_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "email" => _email,
               "id" => _id,
               "message" => "User Removido",
               "name" => "Tarcisio"
             } = response
    end

    test "error delete - tenta remover User sem token de acesso", state do
      %User{id: id = insert(:User)}

      response =
        state[:conn]
        |> delete(Routes.User_path(state[:conn], :delete, id))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error delete - tenta apagar User passando id que não existe ou já foi deletado previamente",
         state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.User_path(state[:conn], :delete, 100_001))
        |> json_response(:not_found)

      assert %{
               "error" => "User not found."
             } = response
    end
  end
end
