defmodule BankApiWeb.AccountTypeTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.AccountType
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Module test Account Type Controller
  """
  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    {:ok,
     valores: %{
       token: token
     }}
  end

  test "all parametes are ok, create AccountType", state do
    params = %{"account_type_name" => "Corrente23"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.account_type_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "mensagem" => "Account Type created successfully!",
             "Account Type" => %{"account_type_name" => "Corrente23"}
           } = response
  end

  test "Record Account Type, then update some data", state do
    %AccountType{id: id} = insert(:account_type)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> patch(
        Routes.account_type_path(state[:conn], :update, id, %{
          account_type_name: "Savings Account"
        })
      )
      |> json_response(:ok)

    assert %{
             "mensagem" => "Account Type updated successfully!",
             "Account Type" => %{"account_type_name" => "Savings Account"}
           } = response
  end

  test "When valid ID is sent, Account Type is deleted", state do
    %AccountType{id: id} = insert(:account_type)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.account_type_path(state[:conn], :delete, id))
      |> json_response(:ok)

    assert %{
             "Name" => "Savings Account",
             "mensagem" => "Account Type deleted successfully!"
           } = response
  end

  test "return error when sent invalid ID", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.account_type_path(state[:conn], :delete, 000_000_000))
      |> json_response(:not_found)

    assert %{
             "error" => "Invalid ID or inexistent."
           } = response
  end

  test "return account info when sent currect ID", state do
    %AccountType{id: id} = insert(:account_type)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.account_type_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Account Type found.",
             "Account Type" => %{"account_type_name" => "Savings Account"}
           } = response
  end

  test "return error info when theres sent invalid ID", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.account_type_path(state[:conn], :show, 000_000_000))
      |> json_response(:not_found)

    assert %{
             "error" => "Invalid ID or inexistent."
           } = response
  end
end
