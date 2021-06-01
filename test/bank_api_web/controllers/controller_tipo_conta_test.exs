defmodule BankApiWeb.Usuario.TipoContaTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.TipoConta
  import BankApi.Factory

  describe "show/2" do
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


  end
end
