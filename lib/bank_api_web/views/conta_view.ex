defmodule BankApiWeb.ContaView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Conta
  alias Ecto.Changeset

  # def render("show.json", %{conta: %Conta{nome_conta: _nome_conta}}) do
  #   %{
  #     mensagem: "Tipo Conta encotrado"
  #     # "Tipo Conta": %{nome_conta: nome_conta}
  #   }
  # end

  def render("create.json", %{
        conta: %Conta{
          saldo_conta: saldo_conta,
          usuario_id: usuario_id,
          tipo_conta_id: tipo_conta_id
        }
      }) do
    %{
      mensagem: "Conta Cadastrada",
      Conta: %{
        saldo_conta: saldo_conta,
        usuario_id: usuario_id,
        tipo_conta_id: tipo_conta_id
      }
    }
  end

  # def render("update.json", %{conta: %Conta{nome_conta: nome_conta}}) do
  #   %{
  #     mensagem: "Conta Atualizada",
  #     Conta: %{nome_conta: nome_conta}
  #   }
  # end

  # def render("delete.json", %{conta: %Conta{nome_conta: nome_conta}}) do
  #   %{
  #     mensagem: "Conta #{nome_conta} removida com sucesso."
  #   }
  # end

  # def render("delete.json", %{error: error}) do
  #   %{
  #     Resultado: "Conta inexistente.",
  #     Mensagem: "#{error}"
  #   }
  # end

  # def render(
  #       "error.json",
  #       %{error: %Changeset{errors: [nome_conta: {"has already been taken", _error}]}} =
  #         _params
  #     ) do
  #   %{error: "Usuario já cadastrado com esse email"}
  # end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
