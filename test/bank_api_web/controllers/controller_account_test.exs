defmodule BankApiWeb.ControllerAccountTest do
  @moduledoc """
  Module test Account Controller
  """

  use BankApiWeb.ConnCase, async: true

  alias BankApi.Schemas.{User, AccountType, Account}
  alias BankApiWeb.Auth.Guardian

  import BankApi.Factory


  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    {:ok,
     valores: %{
       token: token
     }}
  end

  describe "SHOW" do
    test "assert get - Show Account when pass correct ID",
         state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: account_id} =
        insert(:account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.account_path(state[:conn], :show, account_id))
        |> json_response(:ok)

      assert %{
               "account" => %{
                 "balance_account" => 100_000,
                 "account_type_id" => ^account_type_id,
                 "user_id" => ^user_id
               },
               "message" => "Account Type found."
             } = response
    end

    test "error show - Sow erro message when don't have token access.", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: account_id} =
        insert(:account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> get(Routes.account_path(state[:conn], :show, account_id))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error get - Show Account data when get correct ID", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.account_path(state[:conn], :show, 951_951))
        |> json_response(:not_found)

      assert %{"error" => "Invalid ID or inexistent."} = response
    end
  end

  describe "CREATE" do
    test "insert Account - Record Account when all parameters are OK", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      params = %{
        "balance_account" => 100_000,
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.account_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "account" => %{
                 "balance_account" => 100_000,
                 "account_type_id" => _83,
                 "user_id" => _147
               },
               "message" => "Account recorded."
             } = response
    end

    test "assert ok insert Account - Record Account without balance, default 100_000", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      params = %{
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.account_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "account" => %{
                 "balance_account" => 100_000,
                 "account_type_id" => _83,
                 "user_id" => _147
               },
               "message" => "Account recorded."
             } = response
    end

    test "erro insert Account - Show error message when send negative balance.", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      params = %{
        "balance_account" => -10_000,
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.account_path(state[:conn], :create, params))
        |> json_response(404)

      assert %{"error" => "Balance Account should be higher or equal zero."} = response
    end
  end

  describe "UPDATE" do
    test "assert update - update balance to value higher than zero.", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => 5_000}))
        |> json_response(:created)

      assert %{
               "message" => "Account updated.",
               "account" => %{"account_id" => _user_id, "balance_account" => 5000}
             } = response
    end

    test "assert update - update balance to value equal zero.",
         state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:account, user_id: user_id, account_type_id: account_type_id)
      params = %{"balance_account" => 0}

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.account_path(state[:conn], :update, id, params))
        |> json_response(:created)

      assert %{
               "message" => "Account updated.",
               "account" => %{"account_id" => _user_id, "balance_account" => 0}
             } = response
    end

    test "error update - try update balance to value lower than zero", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => -1}))
        |> json_response(404)

      assert %{"error" => "Balance Account should be higher or equal zero."} = response
    end

    test "error update - try update balance without access token", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => -1}))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end

  describe "DELETE" do
    test "assert delete - Delete account when correct ID is sent", state do
      %User{id: user_id} = insert(:user)
      %AccountType{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.account_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "account" => %{"user_id" => ^user_id, "account_type" => ^account_type_id},
               "message" => "Account deleted."
             } = response
    end

    test "error delete - try delete Account with invalid ID", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.account_path(state[:conn], :delete, 951_951_951))
        |> json_response(:not_found)

      assert %{"error" => "Invalid ID or inexistent."} = response
    end

    test "error delete - Try delete Accutn without access token", state do
      response =
        state[:conn]
        |> delete(Routes.account_path(state[:conn], :delete, 951_951_951))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end
end
