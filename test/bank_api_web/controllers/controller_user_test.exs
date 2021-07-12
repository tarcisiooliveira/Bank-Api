defmodule BankApiWeb.ControllerUserTest do
  @moduledoc """
  Module test User Controller
  """

  use BankApiWeb.ConnCase, async: true

  import BankApi.Factory

  alias BankApi.Schemas.{User, Admin}
  alias BankApiWeb.Auth.Guardian

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
      %User{id: user_id} = insert(:user)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.user_path(state[:conn], :show, user_id))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Show",
               "user" => %{"email" => _email, "id" => _id, "name" => "Tarcisio"}
             } = response
    end

    test "error show - retorna erro quando não passa  toke de autorização", state do
      %User{id: user_id} = insert(:user)

      response =
        state[:conn]
        |> get(Routes.user_path(state[:conn], :show, user_id))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error show - Exibe os dados de uma Account quando informado ID errado", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.user_path(state[:conn], :show, 951_951))
        |> json_response(:not_found)

      assert %{"error" => "Invalid ID or inexistent."} = response
    end
  end

  describe "CREATE" do
    test "assert create - create User", state do
      params = %{
        "name" => "Tarcisio",
        "email" => "tarcisiooliveira@protonmail.com",
        "password" => "123456",
        "password_validation" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.user_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Usuário criado com sucesso!",
               "user" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => _id,
                 "name" => "Tarcisio"
               }
             } = response
    end

    test "error assert - try create user without access token", state do
      params = %{
        "name" => "Tarcisio",
        "email" => "tarcisiooliveira@protonmail.com",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> post(Routes.user_path(state[:conn], :create, params))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error insert - try creat user with email already in use",
         state do
      %User{email: email} = insert(:user)

      params = %{
        "email" => email,
        "name" => "Tarcisio2",
        "password" => "123456",
        "password_validation" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.user_path(state[:conn], :create, params))
        |> json_response(:unprocessable_entity)

      assert %{
               "message" => "Email already in use."
             } = response
    end
  end

  describe "UPDATE" do
    test "update email to valid email not in use", state do
      %User{id: id} = insert(:user)
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.user_path(state[:conn], :update, id, params))
        |> json_response(:ok)

      assert %{
               "mensagem" => "User updated successfuly!",
               "user" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => _id,
                 "name" => "Tarcisio"
               }
             } = response
    end

    test "error update - try remove User without accest token", state do
      %User{id: id} = insert(:user)

      params = %{
        "email" => "email@email.com",
        "name" => "Tarcisio",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> patch(Routes.user_path(state[:conn], :update, id, params))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error update - try update to email already in use",
         state do
      %User{id: id} = insert(:user)
      insert(:user, email: "tarcisiooliveira@protonmail.com")
      params = %{email: "tarcisiooliveira@protonmail.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.user_path(state[:conn], :update, id, params))
        |> json_response(:not_found)

      assert %{"error" => "Email already in use."} = response
    end

    test "assert update - Update name", state do
      %User{id: id} = insert(:user, email: "tarcisiooliveira@protonmail.com")
      params = %{name: "oisicraT"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.user_path(state[:conn], :update, id, params))
        |> json_response(:ok)

      assert %{
               "mensagem" => "User updated successfuly!",
               "user" => %{
                 "email" => "tarcisiooliveira@protonmail.com",
                 "id" => ^id,
                 "name" => "oisicraT"
               }
             } = response
    end
  end

  describe "DELETE" do
    test "assert delete - return User data recent deleted and confirmation message",
         state do
      %User{id: id} = insert(:user)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.user_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "email" => _email,
               "id" => _id,
               "message" => "User deleted",
               "name" => "Tarcisio"
             } = response
    end

    test "error delete - try dele User without access token", state do
      %User{id: id = insert(:user)}

      response =
        state[:conn]
        |> delete(Routes.user_path(state[:conn], :delete, id))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error delete - try delete User with invalid ID",
         state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.user_path(state[:conn], :delete, 100_001))
        |> json_response(:not_found)

      assert %{
               "error" => "User not found."
             } = response
    end
  end
end
