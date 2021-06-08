defmodule BankApiWeb.ContaView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Conta
  alias Ecto.Changeset

  def render("show.json", %{
        conta: %Conta{
          saldo_conta: saldo_conta,
          usuario_id: usuario_id,
          tipo_conta_id: tipo_conta_id
        }
      }) do
    %{
      mensagem: "Tipo Conta encotrado",
      Conta: %{
        saldo_conta: saldo_conta,
        usuario_id: usuario_id,
        tipo_conta_id: tipo_conta_id
      }
    }
  end

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

  def render("update.json", %{conta: %Conta{id: id, saldo_conta: saldo_conta}}) do
    %{
      mensagem: "Conta Atualizada",
      Conta: %{conta_ID: id, saldo_conta: saldo_conta}
    }
  end

  def render("delete.json", %{conta: %Conta{usuario_id: usuario_id, tipo_conta_id: tipo_conta_id}}) do
    %{
      mensagem: "Conta removida",
      Conta: %{ID_Usuario: usuario_id, Tipo_Conta: tipo_conta_id}
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Resultado: "Conta inexistente.",
      Mensagem: "#{error}"
    }
  end

  def render(
        "error.json",
        %{error: %Changeset{errors: [saldo_conta: {"is invalid", _error}]}} = _params
      ) do
    %{error: "Saldo inválido, ele deve ser maior ou igual a zero"}
  end

  def render(
        "error.json",
        %{error: error}
      ) do
    %{
      mensagem: error
    }
  end
end
