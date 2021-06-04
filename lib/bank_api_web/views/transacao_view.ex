defmodule BankApiWeb.TransacaoView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Transacao

  def render("show.json", %{
        transacao: %Transacao{
          conta_origem_id: conta_origem_id,
          conta_destino_id: conta_destino_id,
          operacao_id: operacao_id,
          valor: valor
        }
      }) do
    %{
      mensagem: "Transação encotrada",
      Transacao: %{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }
    }
  end

  def render("show.json", %{
        transacao: %Transacao{
          conta_origem_id: conta_origem_id,
          operacao_id: operacao_id,
          valor: valor
        }
      }) do
    %{
      mensagem: "Transação encotrada",
      Transacao: %{conta_origem_id: conta_origem_id, operacao_id: operacao_id, valor: valor}
    }
  end

  def render("create.json", %{
        transacao: %Transacao{
          conta_origem_id: conta_origem_id,
          operacao_id: operacao_id,
          valor: valor
        }
      }) do
    %{
      mensagem: "Transação Criada com Sucesso",
      Transacao: %{conta_origem_id: conta_origem_id, operacao_id: operacao_id, valor: valor}
    }
  end

  def render("create.json", %{
        transacao: %Transacao{
          conta_origem_id: conta_origem_id,
          conta_destino_id: conta_destino_id,
          operacao_id: operacao_id,
          valor: valor
        }
      }) do
    %{
      mensagem: "Transação Criada com Sucesso",
      Transacao: %{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }
    }
  end

  def render("update.json", %{transacao: %Transacao{valor: valor}}) do
    %{
      mensagem: "Operação Atualizada",
      Operação: %{valor: valor}
    }
  end

  def render("delete.json", %{
        transacao: %Transacao{
          id: id,
          conta_origem_id: conta_origem_id,
          conta_destino_id: conta_destino_id,
          operacao_id: operacao_id,
          valor: valor
        }
      }) do
    %{
      mensagem: "Transacao número #{id} removida com sucesso.",
      Transação: %{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }
    }
  end

  def render("delete.json", %{
        transacao: %Transacao{
          id: id,
          conta_origem_id: conta_origem_id,
          operacao_id: operacao_id,
          valor: valor
        }
      }) do
    %{
      mensagem: "Transacao número #{id} removida com sucesso.",
      Transação: %{conta_origem_id: conta_origem_id, operacao_id: operacao_id, valor: valor}
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Resultado: "Operação inexistente.",
      Mensagem: "#{error}"
    }
  end

  # def render(
  #       "error.json",
  #       %{error: %Changeset{errors: [conta_origem_id: {"has already been taken", _error}]}} =
  #         _params
  #     ) do
  #   %{error: "Usuario já cadastrado com esse email"}
  # end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
