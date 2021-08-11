defmodule BankApiWeb.UserControllerTest do
  @moduledoc """
  Module test User Controller
  """

  use BankApiWeb.ConnCase, async: true

  alias BankApi.Users.Schemas.User
  alias BankApiWeb.Auth.GuardianUser

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    {:ok, %{insert_user: user, insert_account: account}} =
      %{
        name: "Tarcisio",
        email: "tarcisio2@ymail.com",
        password: "123456",
        password_validation: "123456"
      }
      |> BankApi.Multi.User.create()

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
      "email" => "tarcisiooliveira@protonmail.com",
      "password" => "123456",
      "password_validation" => "123456"
    }

    response =
      state[:conn]
      |> post(Routes.user_path(state[:conn], :sign_up, params))
      |> json_response(:ok)

    assert %{
             "message" => "User created sucessfuly!",
             "user" => %{
               "email" => "tarcisiooliveira@protonmail.com",
               "user_id" => _user_id
             },
             "account" => %{
               "account_id" => _account_id,
               "balance_account" => 10_000
             }
           } = response
  end

  test "assert sig_in_user test", %{conn: conn} do
    params = %{"email" => "tarcisio2@ymail.com", "password" => "123456"}

    response =
      conn
      |> get(Routes.user_path(conn, :sign_in, params))
      |> json_response(:ok)

    assert %{
             "message" => _token
           } = response
  end

  test "assert show user data when send valid id", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> get(Routes.user_path(state[:conn], :show, %{id: state[:value].user.id}))

    assert %{
             assigns: %{
               user: %User{
                 email: _email,
                 id: _id
               }
             }
           } = response
  end

  test "error show - Show eror message when past invalid id.", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> get(Routes.user_path(state[:conn], :show, %{id: Ecto.UUID.autogenerate()}))

    assert %{"error" => "User not Found"} = Jason.decode!(response.resp_body)
  end

  test "error show - retorna erro quando não passa  toke de autorização", state do
    response =
      state[:conn]
      |> get(Routes.user_path(state[:conn], :show, id: state[:value].user.id))

    assert %{"messagem" => "Authorization Denied"} = Jason.decode!(response.resp_body)
  end

  test "error insert - try creat user with email already in use",
       state do
    params = %{
      "email" => state[:value].user.email,
      "name" => "Tarcisio2",
      "password" => "123456",
      "password_validation" => "123456"
    }

    response =
      state[:conn]
      |> post(Routes.user_path(state[:conn], :sign_up, params))
      |> json_response(:unprocessable_entity)

    assert %{"error" => "Email in use. Choose another."} = response
  end

  test "error insert - try creat user without passwor_validation",
       state do
    params = %{
      "email" => "email@email.com",
      "name" => "Tarcisio2",
      "password" => "123456"
    }

    response =
      state[:conn]
      |> post(Routes.user_path(state[:conn], :sign_up, params))

    assert %{"error" => "Invalid parameters"} = Jason.decode!(response.resp_body)
  end
end
