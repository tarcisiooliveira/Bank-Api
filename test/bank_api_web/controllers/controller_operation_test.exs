defmodule BankApiWeb.ControllerOperationTest do
  use BankApiWeb.ConnCase, async: true
  import BankApi.Factory
  alias BankApi.Schemas.Operation
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Module test Operation Controller
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

  test "socesso insert - insert Operation, return values inserted",
       state do
    params = %{"operation_name" => "Savings Account"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.operation_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Operação" => %{"operation_name" => "Savings Account"},
             "mensagem" => "Operation Recorded"
           } = response
  end

  test "erro insert - try record operation when its already exist", state do
    insert(:operation)
    params = %{"operation_name" => "Transfer"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.operation_path(state[:conn], :create, params))
      |> json_response(404)

    assert %{
             "error" => "Previously registered operation."
           } = response
  end

  test "sucesso delete - return success message when Operation is deleted.",
       state do
    %Operation{id: id} = insert(:operation)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.operation_path(state[:conn], :delete, id))
      |> json_response(:ok)

    assert %{"mensagem" => "Operation Transfer deleted successfully."} = response
  end

  test "error delete - return error message when try remove inexistente Operation",
       state do
    insert(:operation)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.operation_path(state[:conn], :delete, 901_000_000))
      |> json_response(404)

    assert %{"Mensagem" => "Invalid ID or inexistent.", "Result" => "Non-existent operation."} =
             response
  end

  test "sucesso update - Update Opertion", state do
    %Operation{id: id} = insert(:operation)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> patch(
        Routes.operation_path(state[:conn], :update, id, %{operation_name: "New Transfer"})
      )
      |> json_response(:created)

    assert %{
             "Operação" => %{"operation_name" => "New Transfer"},
             "mensagem" => "Operation Updated"
           } = response
  end
end
