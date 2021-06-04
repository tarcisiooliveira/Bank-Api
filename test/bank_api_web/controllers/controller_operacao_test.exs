defmodule BankApiWeb.ControllerOperacaoTest do
  use BankApiWeb.ConnCase, async: true
  import BankApi.Factory
  alias BankApi.Schemas.Operacao

  test "socesso insert - insere Operacão no banco e retorna confirmação e os dados inseridos",
       %{conn: conn} do
    params = %{"nome_operacao" => "Poupança"}

    response =
      conn
      |> post(Routes.operacao_path(conn, :create, params))
      |> json_response(:created)

    assert %{
             "Operação" => %{"nome_operacao" => "Poupança"},
             "mensagem" => "Operação Cadastrada"
           } = response
  end

  test "erro insert - tenta cadastrar Operação com tipo já existente", %{conn: conn} do
    insert(:operacao)
    params = %{"nome_operacao" => "Pagamento"}

    response =
      conn
      |> post(Routes.operacao_path(conn, :create, params))
      |> json_response(404)

    assert %{
             "error" => "Operação já cadastrada previamente."
           } = response
  end

  test "sucesso delete - retorna mensagem de sucesso quando remove operação já cadastrado.", %{
    conn: conn
  } do
    %Operacao{id: id} = insert(:operacao)

    response =
      conn
      |> delete(Routes.operacao_path(conn, :delete, id))
      |> json_response(:ok)

    assert %{"mensagem" => "Operacao Pagamento removida com sucesso."} = response
  end

  test "error delete - retorna mensagem de erro quando tenta remover operação inexistente.", %{
    conn: conn
  } do
    insert(:operacao)

    response =
      conn
      |> delete(Routes.operacao_path(conn, :delete, 901_000_000))
      |> json_response(404)

    assert %{"Mensagem" => "ID Inválido ou inexistente", "Resultado" => "Operação inexistente."} =
             response
  end

  test "sucesso update - atualiza Operacao previamente cadastrada", %{conn: conn} do
    %Operacao{id: id} = insert(:operacao)

    response =
      conn
      |> patch(Routes.operacao_path(conn, :update, id, %{nome_operacao: "Nova Transferência"}))
      |> json_response(:created)

    assert %{
             "Operação" => %{"nome_operacao" => "Nova Transferência"},
             "mensagem" => "Operação Atualizada"
           } = response
  end
end
