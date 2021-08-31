defmodule BankApiWeb.AdminControllerTest do
  @moduledoc """
  Module test Admin Controller
  """

  use BankApiWeb.ConnCase, async: false

  alias BankApiWeb.Auth.GuardianAdmin

  import BankApi.Factory

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)
    {:ok, token, _claims} = GuardianAdmin.encode_and_sign(admin)

    {:ok,
     value: %{
       token: token,
       admin: admin
     }}
  end

  describe "CREATE" do
    test "assert sign_up - create admin when token access is sent", state do
      params = %{
        "email" => "test22@admin.com",
        "password" => "123456",
        "password_confirmation" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:value].token)
        |> post(Routes.admin_path(state[:conn], :sign_up, params))

      assert %{
               "admin" => %{
                 "email" => _test2admincom,
                 "id" => _4c1f1713af7749aa8c5e087062392890
               },
               "message" => "Admin Created."
             } = Jason.decode!(response.resp_body)
    end

    test "error create admin - try create admin without required parameter password_confirmation",
         state do
      params = %{
        "email" => "test2@admin.com",
        "password" => "123456"
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:value].token)
        |> post(Routes.admin_path(state[:conn], :sign_up, params))

      assert %{
               "errors" => %{"password_confirmation" => ["can't be blank"]}
             } = Jason.decode!(response.resp_body)
    end

    test "assert sig_in_admin test", state do
      params = %{
        "email" => state[:value].admin.email,
        "password" => state[:value].admin.password
      }

      response =
        state[:conn]
        |> post(Routes.admin_path(state[:conn], :sign_in, params))

      assert %{
               "token" => _token
             } = Jason.decode!(response.resp_body)
    end

    test "error - trry sig_up_admin without token", state do
      params = %{
        "email" => "admin@email.com",
        "password" => "123456",
        "password_confirmation" => "123456"
      }

      response =
        state[:conn]
        |> post(Routes.admin_path(state[:conn], :sign_up, params))

      assert %{"message" => "unauthorized"} = Jason.decode!(response.resp_body)
    end
  end
end
