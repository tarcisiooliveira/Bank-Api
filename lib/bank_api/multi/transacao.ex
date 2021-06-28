defmodule BankApi.Multi.Transacao do
  alias BankApi.Schemas.{Transacao, Conta}
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Conta, as: HandleContaRepo
  alias BankApi.Handle.Repo.Operacao, as: HandleOperacaoRepo
  alias BankApi.Handle.Repo.Transacao, as: HandleTransacaoRepo

  def create(
        %{
          "conta_origem_id" => conta_origem_id,
          "conta_destino_id" => conta_destino_id,
          "operacao_id" => operacao_id,
          "valor" => valor
        } = _params
      ) do
    saldo_inteiro = String.to_integer(valor)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:mesma_conta, fn _, _ ->
        case is_mesma_conta?(conta_origem_id, conta_destino_id) do
          true -> {:error, :transferencia_para_conta_origem}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:valor_negativo, fn _, _ ->
        case is_valor_negativo?(saldo_inteiro) do
          true -> {:error, :valor_zero_ou_negativo}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:conta_origem, fn _, _ -> buscar_conta(conta_origem_id) end)
      |> Ecto.Multi.run(:operacao, fn _, _ -> buscar_operacao(operacao_id) end)
      |> Ecto.Multi.run(:saldo_insuficiente, fn _, %{conta_origem: conta_origem} ->
        case is_saldo_suficiente?(conta_origem.saldo_conta, saldo_inteiro) do
          true -> {:ok, :saldo_suficiente}
          false -> {:error, :saldo_insuficiente}
        end
      end)
      |> Ecto.Multi.run(:conta_destino, fn _, _ -> buscar_conta(conta_destino_id) end)
      |> Ecto.Multi.update(:changeset_saldo_conta_origem, fn %{conta_origem: conta_origem} ->
        operacao(conta_origem, saldo_inteiro, :subtrair)
      end)
      |> Ecto.Multi.update(:changeset_saldo_conta_destino, fn %{conta_destino: conta_destino} ->
        operacao(conta_destino, saldo_inteiro, :adicionar)
      end)
      |> Ecto.Multi.insert(:cria_transacao, fn %{
                                                 conta_origem: conta_origem,
                                                 conta_destino: conta_destino
                                               } ->
        cria_transacao(conta_origem.id, conta_destino.id, operacao_id, saldo_inteiro)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def create(%{
        "conta_origem_id" => conta_origem_id,
        "operacao_id" => operacao_id,
        "valor" => valor
      }) do
    saldo_inteiro = String.to_integer(valor)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:valor_negativo, fn _, _ ->
        case is_valor_negativo?(saldo_inteiro) do
          true -> {:error, :valor_zero_ou_negativo}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:conta_origem, fn _, _ -> buscar_conta(conta_origem_id) end)
      |> Ecto.Multi.run(:operacao, fn _, _ -> buscar_operacao(operacao_id) end)
      |> Ecto.Multi.run(:saldo_transcao_insuficiente, fn _, %{conta_origem: conta_origem} ->
        case is_saldo_suficiente?(conta_origem.saldo_conta, saldo_inteiro) do
          true -> {:ok, :saldo_suficiente}
          false -> {:error, :saldo_insuficiente}
        end
      end)
      |> Ecto.Multi.update(:changeset_saldo_conta_origem, fn %{conta_origem: conta_origem} ->
        operacao(conta_origem, saldo_inteiro, :subtrair)
      end)
      |> Ecto.Multi.insert(:cria_transacao, fn %{conta_origem: conta_origem} ->
        cria_transacao(conta_origem.id, operacao_id, saldo_inteiro)
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def delete(id) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:buscar_transacao, fn _, _ -> fetch_transacao(id) end)
      |> Ecto.Multi.delete(:conta_deletar, fn %{buscar_transacao: conta} ->
        deletar_conta(conta)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp cria_transacao(conta_origem_id, conta_destino_id, operacao, valor) do
    %{
      conta_origem_id: conta_origem_id,
      conta_destino_id: conta_destino_id,
      operacao_id: operacao,
      valor: valor
    }
    |> Transacao.changeset()
  end

  defp cria_transacao(conta_origem_id, operacao, valor) do
    %{conta_origem_id: conta_origem_id, operacao_id: String.to_integer(operacao), valor: valor}
    |> Transacao.changeset()
  end

  defp buscar_conta(id) do
    case HandleContaRepo.get_account(id) do
      nil -> {:error, :conta_nao_encontrada}
      account -> {:ok, account}
    end
  end

  defp fetch_transacao(id) do
    case HandleTransacaoRepo.fetch_transacao(id) do
      nil -> {:error, :transacao_nao_encontrada}
      transacao -> {:ok, transacao}
    end
  end

  defp buscar_operacao(operacao_id) do
    case HandleOperacaoRepo.get_account(operacao_id) do
      nil -> {:error, :operacao_nao_encontrada}
      account -> {:ok, account}
    end
  end

  defp is_mesma_conta?(id_origem, id_destino) do
    id_origem == id_destino
  end

  defp is_valor_negativo?(value) do
    if value == 0 or Decimal.new(value) |> Decimal.negative?(), do: true, else: false
  end

  defp is_saldo_suficiente?(saldo_inicial, valor),
    do: if(saldo_inicial - valor >= 0, do: true, else: false)

  defp deletar_conta(conta) do
    conta
    |> HandleContaRepo.delete(conta)
  end

  defp deletar_transacao(transacao) do
    transacao
    |> HandleTransacaoRepo.delete(transacao)
  end

  defp operacao(conta, valor, :subtrair) do
    conta
    |> Conta.update_changeset(%{saldo_conta: conta.saldo_conta - valor})
  end

  defp operacao(conta, valor, :adicionar) do
    conta
    |> Conta.update_changeset(%{saldo_conta: conta.saldo_conta + valor})
  end
end
