defmodule BankApiWeb.TipoContaTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.TipoConta
  import BankApi.Factory
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

  test "quando todos parametros estão ok, cria TipoConta no banco", state do
    params = %{"nome_tipo_conta" => "Corrente23"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.tipo_conta_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "mensagem" => "Tipo Conta criado com sucesso!",
             "Tipo Conta" => %{"nome_tipo_conta" => "Corrente23"}
           } = response
  end

  test "cadastra Tipo de Conta corretamente e depois atualiza a informação", state do
    %TipoConta{id: id} = insert(:tipo_conta)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> patch(
        Routes.tipo_conta_path(state[:conn], :update, id, %{nome_tipo_conta: "Poupança Digital"})
      )
      |> json_response(:ok)

    assert %{
             "mensagem" => "Tipo Conta alterado com sucesso!",
             "Tipo Conta" => %{"nome_tipo_conta" => "Poupança Digital"}
           } = response
  end

  test "usuario passa id válido e então o Tipo Conta é apagado", state do
    %TipoConta{id: id} = insert(:tipo_conta)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.tipo_conta_path(state[:conn], :delete, id))
      |> json_response(:ok)

    assert %{
             "Nome" => "Poupança Digital",
             "mensagem" => "Tipo Conta removido com sucesso!"
           } = response
  end

  test "retorna erro quando não consegue apagar usuario do banco com ID invalido", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.tipo_conta_path(state[:conn], :delete, 000_000_000))
      |> json_response(:not_found)

    assert %{
             "error" => "ID Inválido"
           } = response
  end

  test "retorna informações de um Tipo Conta presente no banco", state do
    %TipoConta{id: id} = insert(:tipo_conta)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.tipo_conta_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Tipo Conta encotrado",
             "Tipo Conta" => %{"nome_tipo_conta" => "Poupança Digital"}
           } = response
  end

  test "retorna informações de erro quando não encontra Tipo Conta presente no banco", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.tipo_conta_path(state[:conn], :show, 000_000_000))
      |> json_response(:not_found)

    assert %{
             "error" => "ID Inválido"
           } = response
  end
end
