defmodule BankApiWeb.ControllerAdminTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApiWeb.Auth.Guardian
  import BankApi.Factory

  @moduledoc """
  Module test Admin Controller
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
    test "assert create admin - create admin when token access is sent", state do
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
               "mensagem" => "Admin recorded."
             } = response
    end

    test "error create admin - try create admin without required parameter assword_confirmation",
         state do
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

    test "error create admin - try create admin without access token ", state do
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
    test "assert delete ok- remove admin", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.admin_path(state[:conn], :delete, state[:valores].admin.id))
        |> json_response(:ok)

      assert %{"email" => "tarcisio@admin.com", "mensagem" => "Admin deleted."} = response
    end

    test "error delete - try remove inexistent admin", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.admin_path(state[:conn], :delete, 789_456_123))
        |> json_response(404)

      assert %{
               "Erro" => "Admin not deleted.",
               "Result" => "Invalid ID or inexistent."
             } = response
    end

    test "error delete - try remove admin with invalid token", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token <> ".")
        |> delete(Routes.admin_path(state[:conn], :delete, 789_456_123))

      assert %{resp_body: "{\"messagem\":\"invalid_token\"}", status: 401} = response
    end

    test "error delete - try remove admin without access token", state do
      response =
        state[:conn]
        |> delete(Routes.admin_path(state[:conn], :delete, 789_456_123))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end

  describe "UPDATE" do
    test "assert update admin - admin update email", state do
      params = %{email: "updated-email@email.com"}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.admin_path(state[:conn], :update, state[:valores].admin.id, params))
        |> json_response(:ok)

      assert %{"mensagem" => "Admin updated.", "email" => "updated-email@email.com"} = response
    end

    test "error update - try update admin without access token", state do
      response =
        state[:conn]
        |> patch(
          Routes.admin_path(state[:conn], :update, state[:valores].admin.id, %{
            email: "update-email@email.com"
          })
        )

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error update - try update email when thres email alread exist", state do
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
