defmodule BankApi.Multi.Transacao do
  alias BankApi.Schemas.{Transacao, Conta}
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Conta, as: HandleContaRepo
  alias BankApi.Handle.Repo.Operacao, as: HandleOperacaoRepo
  alias BankApi.Handle.Repo.Transacao, as: HandleTransacaoRepo

  def create(%{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:mesma_conta, fn _, _ ->
        case is_mesma_conta?(conta_origem_id, conta_destino_id) do
          true -> {:error, :transferencia_para_conta_origem}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:valor_negativo, fn _, _ ->
        case is_negative_value?(valor) do
          true -> {:error, :valor_zero_ou_negativo}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:conta_origem, fn _, _ -> buscar_conta(%{id: conta_origem_id}) end)
      |> Ecto.Multi.run(:operacao, fn _, _ -> buscar_operacao(%{id: operacao_id}) end)
      |> Ecto.Multi.run(:saldo_insuficiente, fn _, %{conta_origem: conta_origem} ->
        case is_saldo_suficiente?(conta_origem.saldo_conta, valor) do
          true -> {:ok, :saldo_suficiente}
          false -> {:error, :saldo_insuficiente}
        end
      end)
      |> Ecto.Multi.run(:conta_destino, fn _, _ -> buscar_conta(%{id: conta_destino_id}) end)
      |> Ecto.Multi.update(:changeset_saldo_conta_origem, fn %{conta_origem: conta_origem} ->
        operacao(conta_origem, valor, :subtrair)
      end)
      |> Ecto.Multi.update(:changeset_saldo_conta_destino, fn %{conta_destino: conta_destino} ->
        operacao(conta_destino, valor, :adicionar)
      end)
      |> Ecto.Multi.insert(:cria_transacao, fn %{
                                                 conta_origem: conta_origem,
                                                 conta_destino: conta_destino
                                               } ->
        cria_transacao(conta_origem.id, conta_destino.id, operacao_id, valor)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def create(%{
        conta_origem_id: conta_origem_id,
        operacao_id: operacao_id,
        valor: valor
      }) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:valor_negativo, fn _, _ ->
        case is_negative_value?(valor) do
          true -> {:error, :valor_zero_ou_negativo}
          false -> {:ok, false}
        end
      end)
      |> Ecto.Multi.run(:conta_origem, fn _, _ -> buscar_conta(%{id: conta_origem_id}) end)
      |> Ecto.Multi.run(:operacao, fn _, _ -> buscar_operacao(%{id: operacao_id}) end)
      |> Ecto.Multi.run(:saldo_transcao_insuficiente, fn _, %{conta_origem: conta_origem} ->
        case is_saldo_suficiente?(conta_origem.saldo_conta, valor) do
          true -> {:ok, :saldo_suficiente}
          false -> {:error, :saldo_insuficiente}
        end
      end)
      |> Ecto.Multi.update(:changeset_saldo_conta_origem, fn %{conta_origem: conta_origem} ->
        operacao(conta_origem, valor, :subtrair)
      end)
      |> Ecto.Multi.insert(:cria_transacao, fn %{conta_origem: conta_origem} ->
        cria_transacao(conta_origem.id, operacao_id, valor)
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_transaction, fn _, _ -> fetch_transaction(id) end)
      |> Ecto.Multi.delete(:delete_account, fn %{fetch_transaction: conta} ->
        conta
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

  defp buscar_conta(%{id: _id} = params) do
    case HandleContaRepo.fetch_account(params) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end

  defp fetch_transaction(id) do
    case HandleTransacaoRepo.fetch_transaction(id) do
      nil -> {:error, :transaction_not_found}
      transacao -> {:ok, transacao}
    end
  end

  defp buscar_operacao(%{id: _operation_id} = params) do
    case HandleOperacaoRepo.fetch_operation(params) do
      nil -> {:error, :operation_not_found}
      operation -> {:ok, operation}
    end
  end

  defp is_mesma_conta?(id_origem, id_destino) do
    id_origem == id_destino
  end

  defp is_negative_value?(value) do
    if value == 0 or Decimal.new(value) |> Decimal.negative?(), do: true, else: false
  end

  defp is_saldo_suficiente?(saldo_inicial, valor),
    do: if(saldo_inicial - String.to_integer(valor) >= 0, do: true, else: false)

  defp operacao(conta, valor, :subtrair) do
    conta
    |> Conta.update_changeset(%{saldo_conta: conta.saldo_conta - String.to_integer(valor)})
  end

  defp operacao(conta, valor, :adicionar) do
    conta
    |> Conta.update_changeset(%{saldo_conta: conta.saldo_conta + String.to_integer(valor)})
  end
end
