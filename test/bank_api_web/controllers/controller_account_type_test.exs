defmodule BankApiWeb.AccountTypeTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.AccountType
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

  test "quando todos parametros estão ok, cria AccountType no banco", state do
    params = %{"account_type_name" => "Corrente23"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.account_type_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "mensagem" => "Tipo Account criado com sucesso!",
             "Tipo Account" => %{"account_type_name" => "Corrente23"}
           } = response
  end

  test "cadastra Tipo de Account corretamente e depois atualiza a informação", state do
    %AccountType{id: id} = insert(:account_type)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> patch(
        Routes.account_type_path(state[:conn], :update, id, %{account_type_name: "Savings Account"})
      )
      |> json_response(:ok)

    assert %{
             "mensagem" => "Tipo Account alterado com sucesso!",
             "Tipo Account" => %{"account_type_name" => "Savings Account"}
           } = response
  end

  test "User passa id válido e então o Tipo Account é apagado", state do
    %AccountType{id: id} = insert(:account_type)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.account_type_path(state[:conn], :delete, id))
      |> json_response(:ok)

    assert %{
             "Nome" => "Savings Account",
             "mensagem" => "Tipo Account removido com sucesso!"
           } = response
  end

  test "retorna erro quando não consegue apagar User do banco com ID invalido", state do
    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> delete(Routes.account_type_path(state[:conn], :delete, 000_000_000))
      |> json_response(:not_found)

    assert %{
             "error" => "Invalid ID or inexistent."
           } = response
  end

  test "retorna informações de um Tipo Account presente no banco", state do
    %AccountType{id: id} = insert(:account_type)

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.account_type_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Tipo Account encotrado",
             "Tipo Account" => %{"account_type_name" => "Savings Account"}
           } = response
  end

  test "retorna informações de erro quando não encontra Tipo Account presente no banco", state do
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
