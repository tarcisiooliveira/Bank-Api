defmodule BankApi.ControllerAdminTest do
  use BankApiWeb.ConnCase, async: false
  alias BankApiWeb.Auth.Guardian
  import BankApi.Factory

  @moduledoc """
  Modulo de teste do Controlador de Admin
  """

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)
    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    {:ok,
     valores: %{
       token: token,
       admin: admin
     }}
  end

  describe "CREATE" do
    test "assert create admin - Cria admin passando token", state do
      params2 = %{
        "email" => "test2@admin.com",
        "password" => "123456",
        "password_confirmation" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.admin_path(state[:conn], :create, params2))
        |> json_response(:created)

      assert %{
               "email" => "test2@admin.com",
               "mensagem" => "Administrador Cadastrado"
             } = response
    end

    test "error create admin - tenta criar admin faltando password_confirmation", state do
      params2 = %{
        "email" => "test2@admin.com",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.admin_path(state[:conn], :create, params2))
        |> json_response(422)

      assert %{
               "error" =>
                 "Invalid parameters.\n        Required: \"email\" => email, \"password\" => password, \"password_confirmation\" => password_confirmation"
             } = response
    end

    test "error create admin - tenta criar admin sem token ", state do
      params2 = %{
        "email" => "test2@admin.com",
        "password" => "123456",
        "password_confirmation" => "123456"
      }

      response =
        state[:conn]
        |> post(Routes.admin_path(state[:conn], :create, params2))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end

  describe "DELETE" do
    test "assert delete ok- remove administrador", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.admin_path(state[:conn], :delete, state[:valores].admin.id))
        |> json_response(:ok)

      assert %{"email" => "tarcisio@admin.com", "mensagem" => "Administrador removido"} = response
    end

    test "error delete - tenta remover administrador inexistente", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.admin_path(state[:conn], :delete, 789_456_123))
        |> json_response(404)

      assert %{
               "Erro" => "Administrador não removido.",
               "Resultado" => "Invalid ID or inexistent."
             } = response
    end

    test "error delete - tenta remover administrador com token invalido", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token <> ".")
        |> delete(Routes.admin_path(state[:conn], :delete, 789_456_123))

      assert %{resp_body: "{\"messagem\":\"invalid_token\"}", status: 401} = response
    end

    test "error delete - tenta remover administrador sem token de acesso", state do
      response =
        state[:conn]
        |> delete(Routes.admin_path(state[:conn], :delete, 789_456_123))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end

  describe "UPDATE" do
    test "assert update admin - admin atualiza email", state do
      params = %{email: "updated-email@email.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.admin_path(state[:conn], :update, state[:valores].admin.id, params))
        |> json_response(:ok)

      assert %{"mensagem" => "Admininstrador Atualizado", "email" => "updated-email@email.com"} =
               response
    end

    test "error update - tenta atualizar admin sem token de acesso", state do
      response =
        state[:conn]
        |> patch(
          Routes.admin_path(state[:conn], :update, state[:valores].admin.id, %{
            email: "update-email@email.com"
          })
        )

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error update - tenta alterar endereço de email para um já cadastrado", state do
      params = %{email: "tarcisio@admin.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.admin_path(state[:conn], :update, state[:valores].admin.id, params))
        |> json_response(:not_found)

      assert %{"error" => "Email already in use."} = response
    end
  end
end
