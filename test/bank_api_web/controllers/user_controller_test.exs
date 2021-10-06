defmodule BankApiWeb.UserControllerTest do
  @moduledoc """
  Module test User Controller
  """

  use BankApiWeb.ConnCase, async: true

  alias BankApi.Users.CreateUser
  alias BankApiWeb.Auth.GuardianUser

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    {:ok, %{insert_user: user, insert_account: account}} =
      %{
        name: "Tarcisio",
        email: "tarcisio2@email.com",
        password: "123456",
        password_confirmation: "123456"
      }
      |> CreateUser.create()

    {:ok, token, _claims} = GuardianUser.encode_and_sign(user)

    {:ok,
     value: %{
       token: token,
       user: user,
       account: account
     }}
  end

  test "assert create - create User and Account", state do
    params = %{
      "name" => "Tarcisio",
      "email" => "tarcisiooliveira@email.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    response =
      state[:conn]
      |> post(Routes.user_path(state[:conn], :sign_up, params))
      |> json_response(:ok)

    assert %{
             "user" => %{
               "email" => "tarcisiooliveira@email.com",
               "id" => _user_id,
               "account" => %{
                 "id" => _account_id,
                 "balance" => 100_000
               }
             }
           } = response
  end

  test "assert sig_in_user test", %{conn: conn} do
    params = %{"email" => "tarcisio2@email.com", "password" => "123456"}

    response =
      conn
      |> post(Routes.user_path(conn, :sign_in, params))
      |> json_response(:ok)

    assert %{
             "token" => _token
           } = response
  end

  test "error insert - try creat user with email already in use",
       state do
    params = %{
      "email" => state[:value].user.email,
      "name" => "Tarcisio2",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    response =
      state[:conn]
      |> post(Routes.user_path(state[:conn], :sign_up, params))
      |> json_response(:unprocessable_entity)

    assert %{"errors" => %{"email" => ["Email already used."]}} = response
  end

  test "error insert - try creat user without passwor_validation",
       state do
    response =
      state[:conn]
      |> post(
        Routes.user_path(state[:conn], :sign_up, %{
          "email" => "email@email.com",
          "name" => "Tarcisio2",
          "password" => "123456"
        })
      )

    assert %{"errors" => %{"password_confirmation" => ["can't be blank"]}} =
             Jason.decode!(response.resp_body)
  end
end
