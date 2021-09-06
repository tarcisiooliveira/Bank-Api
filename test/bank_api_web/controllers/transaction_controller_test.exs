defmodule BankApiWeb.TransactionControllerTest do
  @moduledoc """
  Module test Transaction Controller
  """

  use BankApiWeb.ConnCase
  use ExUnit.Case

  import BankApi.Factory

  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Transaction.Schemas.Transaction
  alias BankApi.Users.Schemas.User
  alias BankApiWeb.Auth.GuardianUser

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    %User{id: user_id1} = user = insert(:user)
    %User{id: user_id2} = insert(:user)
    %User{id: user_id3} = insert(:user)

    {:ok, token, _claims} = GuardianUser.encode_and_sign(user)

    %Account{id: account_id1} = insert(:account, user_id: user_id1)

    %Account{id: account_id2} = insert(:account, user_id: user_id2)

    %Account{id: account_id3} = insert(:account, user_id: user_id3)

    %Transaction{id: id} =
      insert(:withdraw,
        from_account_id: account_id1,
        value: 700
      )

    %Transaction{id: id2} =
      insert(:transfer,
        from_account_id: account_id1,
        to_account_id: account_id2,
        value: 650
      )

    {:ok,
     value: %{
       account_id1: account_id1,
       account_id2: account_id2,
       account_id3: account_id3,
       transaction_id1: id,
       transaction_id2: id2,
       token: token
     }}
  end

  test "assert get - Show payment data.", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> get(Routes.transaction_path(state[:conn], :show, id: state[:value].transaction_id2))
      |> json_response(:ok)

    assert %{
             "message" => "Transaction founded",
             "Transaction" => %{
               "from_account_id" => state[:value].account_id1,
               "to_account_id" => state[:value].account_id2,
               "value" => 650
             }
           } == response
  end

  test "assert get - Show withdraw data when is past valid parameters.",
       state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> get(Routes.transaction_path(state[:conn], :show, id: state[:value].transaction_id1))
      |> json_response(:ok)

    assert %{
             "message" => "Transaction founded",
             "Transaction" => %{
               "from_account_id" => _,
               "value" => 700
             }
           } = response
  end

  test "error - show error message when sent an invalid id.",
       state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> get(
        Routes.transaction_path(state[:conn], :show, id: "c1960fa0-11ae-47fa-b325-68d94a7d7f5d")
      )
      |> json_response(:not_found)

    assert %{"error" => %{"message" => ["Not Found"]}} = response
  end

  test "assert ok insert - alls parameters are ok, User make withdraw", state do
    params = %{"value" => 1000}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.transaction_path(state[:conn], :withdraw, params))
      |> json_response(:ok)

    assert %{
             "Transaction" => %{
               "from_account_id" => _stateaccount_id3,
               "value" => 1000
             },
             "message" => "Transaction finished successfully"
           } = response
  end

  test "error, try a transfer to the same account",
       state do
    state[:conn]
    |> put_req_header("authorization", "Bearer " <> state[:value].token)
    |> Guardian.Plug.current_resource()

    params = %{
      "to_account_id" => state[:value].account_id1,
      "value" => 600
    }

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.transaction_path(state[:conn], :transfer, params))

    assert %{"error" => %{"message" => ["Transfer to the same Account"]}} =
             Jason.decode!(response.resp_body)
  end

  test "assert ok insert transaction/4 - All parameters ok, create a transaction between two Acccounts",
       state do
    params = %{
      "to_account_id" => state[:value].account_id2,
      "value" => 600
    }

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.transaction_path(state[:conn], :transfer, params))
      |> json_response(:ok)

    assert %{
             "Transaction" => %{
               "from_account_id" => _stateaccount_id1,
               "to_account_id" => _stateaccount_id2,
               "value" => 600
             },
             "message" => "Transaction finished successfully"
           } = response
  end
end
