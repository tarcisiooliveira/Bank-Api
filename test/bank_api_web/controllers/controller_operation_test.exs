defmodule BankApiWeb.ControllerOperationTest do
  use BankApiWeb.ConnCase, async: true
  import BankApi.Factory
  alias BankApi.Schemas.Operation
  alias BankApiWeb.Auth.Guardian

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    {:ok,
     valores: %{
       token: token
     }}
  end

  test "socesso insert - insere Operacão no banco e retorna confirmação e os dados inseridos",
       state do
    params = %{"operation_name" => "Poupança"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.operation_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Operação" => %{"operation_name" => "Poupança"},
             "mensagem" => "Operation Recorded"
           } = response
  end

  test "erro insert - tenta cadastrar Operação com tipo já existente", state do
    insert(:operation)
    params = %{"operation_name" => "Transfer"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.operation_path(state[:conn], :create, params))
      |> json_response(404)

    assert %{
             "error" => "Previously registered operation. "
           } = response
  end

  test "sucesso delete - retorna mensagem de sucesso quando remove operação já cadastrado.",
       state do
    %Operation{id: id} = insert(:operation)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.operation_path(state[:conn], :delete, id))
      |> json_response(:ok)

    assert %{"mensagem" => "Operation Transfer deleted successfully."} = response
  end

  test "error delete - retorna mensagem de erro quando tenta remover operação inexistente.",
       state do
    insert(:operation)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.operation_path(state[:conn], :delete, 901_000_000))
      |> json_response(404)

    assert %{"Mensagem" => "Invalid ID or inexistent.", "Resultado" => "Non-existent operation."} =
             response
  end

  test "sucesso update - atualiza Operation previamente cadastrada", state do
    %Operation{id: id} = insert(:operation)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> patch(
        Routes.operation_path(state[:conn], :update, id, %{operation_name: "Nova Transfer"})
      )
      |> json_response(:created)

    assert %{
             "Operação" => %{"operation_name" => "Nova Transfer"},
             "mensagem" => "Operation Updated"
           } = response
  end
end
