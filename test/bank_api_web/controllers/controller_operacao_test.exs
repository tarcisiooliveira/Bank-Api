defmodule BankApiWeb.ControllerOperacaoTest do
  use BankApiWeb.ConnCase, async: true
  import BankApi.Factory
  alias BankApi.Schemas.Operacao
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
    params = %{"nome_operacao" => "Poupança"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.operacao_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Operação" => %{"nome_operacao" => "Poupança"},
             "mensagem" => "Operação Cadastrada"
           } = response
  end

  test "erro insert - tenta cadastrar Operação com tipo já existente", state do
    insert(:operacao)
    params = %{"nome_operacao" => "Transferência"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.operacao_path(state[:conn], :create, params))
      |> json_response(404)

    assert %{
             "error" => "Operação já cadastrada previamente."
           } = response
  end

  test "sucesso delete - retorna mensagem de sucesso quando remove operação já cadastrado.",
       state do
    %Operacao{id: id} = insert(:operacao)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.operacao_path(state[:conn], :delete, id))
      |> json_response(:ok)

    assert %{"mensagem" => "Operacao Transferência removida com sucesso."} = response
  end

  test "error delete - retorna mensagem de erro quando tenta remover operação inexistente.",
       state do
    insert(:operacao)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.operacao_path(state[:conn], :delete, 901_000_000))
      |> json_response(404)

    assert %{"Mensagem" => "ID Inválido ou inexistente", "Resultado" => "Operação inexistente."} =
             response
  end

  test "sucesso update - atualiza Operacao previamente cadastrada", state do
    %Operacao{id: id} = insert(:operacao)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> patch(
        Routes.operacao_path(state[:conn], :update, id, %{nome_operacao: "Nova Transferência"})
      )
      |> json_response(:created)

    assert %{
             "Operação" => %{"nome_operacao" => "Nova Transferência"},
             "mensagem" => "Operação Atualizada"
           } = response
  end
end
