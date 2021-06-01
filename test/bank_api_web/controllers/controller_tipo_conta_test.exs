defmodule BankApiWeb.Usuario.TipoContaTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.TipoConta
  import BankApi.Factory

  describe "Tipo Conta/2" do
    test "quando todos parametros estão ok, cria TipoConta no banco", %{conn: conn} do
      params = %{"nome_tipo_conta" => "Corrente23"}

      response =
        conn
        |> post(Routes.tipo_conta_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "mensagem" => "Tipo Conta criado com sucesso!",
               "Tipo Conta" => %{"nome_tipo_conta" => "Corrente23"}
             } = response
    end

    test "cadastra Tipo de Conta corretamente e depois atualiza a informação", %{
      conn: conn
    } do
      %TipoConta{id: id} = insert(:tipo_conta)

      response =
        conn
        |> patch(
          Routes.tipo_conta_path(conn, :update, id, %{nome_tipo_conta: "Poupança Digital"})
        )
        |> json_response(:ok)

      assert %{
               "mensagem" => "Tipo Conta alterado com sucesso!",
               "Tipo Conta" => %{"nome_tipo_conta" => "Poupança Digital"}
             } = response
    end

    test "usuario passa id válido e então o Tipo Conta é apagado", %{conn: conn} do
      %TipoConta{id: id} = insert(:tipo_conta)

      response =
        conn
        |> delete(Routes.tipo_conta_path(conn, :delete, id))
        |> json_response(:ok)

      assert %{
               "Nome" => "Poupança",
               "mensagem" => "Tipo Conta removido com sucesso!"
             } = response
    end

    test "retorna erro quando não consegue apagar usuario do banco com ID invalido", %{conn: conn} do
      response =
        conn
        |> delete(Routes.tipo_conta_path(conn, :delete, 000_000_000))
        |> json_response(:not_found)

      assert %{
               "error" => "ID Inválido"
             } = response
    end

    test "retorna informações de um Tipo Conta presente no banco", %{conn: conn} do
      %TipoConta{id: id} = insert(:tipo_conta)

      response =
        conn
        |> get(Routes.tipo_conta_path(conn, :show, id))
        |> json_response(:ok)

      assert %{
               "mensagem" => "Tipo Conta encotrado",
               "Tipo Conta" => %{"nome_tipo_conta" => "Poupança"}
             } = response
    end

    test "retorna informações de erro quando não encontra Tipo Conta presente no banco", %{
      conn: conn
    } do
      response =
        conn
        |> get(Routes.tipo_conta_path(conn, :show, 000_000_000))
        |> json_response(:not_found)

      assert %{
               "error" => "ID Inválido"
             } = response
    end
  end
end
