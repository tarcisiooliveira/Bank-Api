defmodule BankApiWeb.TransacaoView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Transacao

  def render(
        "show.json",
        %{
          transacao:
            {:ok,
             %Transacao{
               conta_origem_id: conta_origem_id,
               conta_destino_id: nil,
               operacao_id: operacao_id,
               valor: valor
             }}
        } = params
      ) do
    %{
      mensagem: "Transação encotrada",
      Transacao: %{conta_origem_id: conta_origem_id, operacao_id: operacao_id, valor: valor}
    }
  end

  def render(
        "show.json",
        %{
          transacao:
            {:ok,
             %Transacao{
               conta_origem_id: conta_origem_id,
               conta_destino_id: conta_destino_id,
               operacao_id: operacao_id,
               valor: valor
             }}
        } = params
      ) do
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

  def render(
        "create.json",
        %{
          transacao:
            {:ok,
             %{
               cria_transacao: %Transacao{
                 conta_origem_id: conta_origem_id,
                 conta_destino_id: nil,
                 operacao_id: operacao_id,
                 valor: valor
               }
             }}
        } = _params
      ) do
    %{
      mensagem: "Transação Realizada com Sucesso",
      Transacao: %{
        conta_origem_id: conta_origem_id,
        operacao_id: operacao_id,
        valor: valor
      }
    }
  end

  def render(
        "create.json",
        %{
          transacao:
            {:ok,
             %{
               cria_transacao: %Transacao{
                 conta_origem_id: conta_origem_id,
                 conta_destino_id: conta_destino_id,
                 operacao_id: operacao_id,
                 valor: valor
               }
             }}
        } = _params
      ) do
    %{
      mensagem: "Transação Realizada com Sucesso",
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

  def render(
        "delete.json",
        %{
          transacao: %{
            conta_origem_id: conta_origem_id,
            conta_destino_id: nil,
            operacao_id: operacao_id,
            valor: valor
          }
        }
      ) do
    %{
      mensagem: "Transação Removida com Sucesso",
      Transacao: %{
        conta_origem_id: conta_origem_id,
        operacao_id: operacao_id,
        valor: valor
      }
    }
  end

  def render(
        "delete.json",
        %{
          transacao: %{
            conta_origem_id: conta_origem_id,
            conta_destino_id: conta_destino_id,
            operacao_id: operacao_id,
            valor: valor
          }
        }
      ) do
    %{
      mensagem: "Transação Removida com Sucesso2",
      Transacao: %{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Resultado: "Operação inexistente.",
      Mensagem: "#{error}"
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
end
