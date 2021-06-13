defmodule BankApi.ControllerAdminTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Admin}
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Modulo de teste do Controlador de Admin
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

  describe "create" do
    test "Test criacao admin com token", state do
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
               "admin" => %{"email" => "test2@admin.com", "password_hash" => _password_hash},
               "mensagem" => "Administrador Cadastrado",
               "token" => _token
             } = response
    end
  end
end
