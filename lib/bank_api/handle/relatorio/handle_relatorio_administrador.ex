defmodule BankApi.Handle.Relatorio.HandleRelatorioAdministrador do
  alias BankApi.Schemas.{Transacao, Conta, Operacao}
  alias BankApi.Repo
  import Ecto.Query

  def conta_valida?(id_conta) do
    case Repo.get_by(Conta, id: id_conta) do
      %Conta{} -> true
      _ -> false
    end
  end

  def relatorio(
        %{
          "periodo_inicial" => periodo_inicial,
          "periodo_final" => periodo_final,
          "conta_origem_id" => conta_origem_id,
          "conta_destino_id" => conta_destino_id,
          "operacao" => operacao
        } = _params
      ) do
    case conta_valida?(conta_origem_id) &&
           conta_valida?(conta_destino_id) &&
           validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transacao,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            where:
              o.nome_operacao == ^operacao and
                t.conta_destino_id == ^conta_destino_id and
                t.conta_origem_id == ^conta_origem_id and
                t.inserted_at > ^periodo_inicial and
                t.inserted_at < ^periodo_final,
            select: t.valor

        quantidade =
          Repo.all(query)
          |> Enum.count()

        case quantidade do
          0 ->
            retorno = %{
              conta_origem_id: conta_origem_id,
              conta_destino_id: conta_destino_id,
              mensagem: "Total durante determinado período entre duas contas.",
              operacao: operacao,
              resultado: 0
            }

            {:ok, retorno}

          _ ->
            resultado = Repo.aggregate(query, :sum, :valor)

            retorno = %{
              conta_origem_id: conta_origem_id,
              conta_destino_id: conta_destino_id,
              mensagem: "Total durante determinado período entre duas contas.",
              operacao: operacao,
              resultado: resultado
            }

            {:ok, retorno}
        end

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique Id da Conta, Data ou Operção."
         }}
    end
  end

  def relatorio(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "conta_origem_id" => conta_origem_id,
        "operacao" => operacao
      }) do
    case conta_valida?(conta_origem_id) &&
           validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transacao,
            join: c in Conta,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            on: t.conta_origem_id == c.id,
            where:
              t.conta_origem_id == ^conta_origem_id and t.inserted_at >= ^periodo_inicial and
                t.inserted_at <= ^periodo_final and o.nome_operacao == ^operacao,
            select: t.valor

        quantidade =
          Repo.all(query)
          |> Enum.count()

        case quantidade do
          0 ->
            retorno = %{
              conta_origem_id: conta_origem_id,
              mensagem: "Total durante determinado período por determinada conta.",
              operacao: operacao,
              resultado: 0
            }

            {:ok, retorno}

          _ ->
            resultado = Repo.aggregate(query, :sum, :valor)

            retorno = %{
              conta_origem_id: conta_origem_id,
              mensagem: "Total durante determinado período por determinada conta.",
              operacao: operacao,
              resultado: resultado
            }

            {:ok, retorno}
        end

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique Id da Conta, Data ou Operção."
         }}
    end
  end

  def relatorio(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "operacao" => operacao
      }) do
    case validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transacao,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            where:
              t.inserted_at >= ^periodo_inicial and
                t.inserted_at <= ^periodo_final and
                o.nome_operacao == ^operacao,
            select: t.valor

        quantidade =
          Repo.all(query)
          |> Enum.count()

        case quantidade do
          0 ->
            retorno = %{
              mensagem: "Total durante determinado período por todas contas.",
              operacao: operacao,
              resultado: 0
            }

            {:ok, retorno}

          _ ->
            resultado = Repo.aggregate(query, :sum, :valor)

            retorno = %{
              mensagem: "Total durante determinado período por todas contas.",
              operacao: operacao,
              resultado: resultado
            }

            {:ok, retorno}
        end

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique a Data ou Operção."
         }}
    end
  end

  def relatorio(%{"conta_origem_id" => conta_origem_id, "operacao" => operacao}) do
    case conta_valida?(conta_origem_id) do
      true ->
        query =
          from t in Transacao,
            join: c in Conta,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            on: t.conta_origem_id == c.id,
            where:
              o.nome_operacao == ^operacao and
                t.conta_origem_id == ^conta_origem_id,
            select: t.valor

        resultado = Repo.aggregate(query, :sum, :valor)

        retorno = %{
          mensagem: "Total realizado por determinada conta.",
          operacao: operacao,
          resultado: resultado
        }

        {:ok, retorno}

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique a Id da Conta ou Operção."
         }}
    end
  end

  def relatorio(%{"periodo" => "todo", "operacao" => operacao}) do
    query =
      from t in Transacao,
        join: o in Operacao,
        on: t.operacao_id == o.id,
        where: o.nome_operacao == ^operacao,
        select: [t.valor]

    quantidade =
      Repo.all(query)
      |> Enum.count()

    case quantidade do
      0 ->
        retorno = %{
          mensagem: "Total durante todo o período",
          operacao: operacao,
          resultado: 0
        }

        {:ok, retorno}

      _ ->
        resultado = Repo.aggregate(query, :sum, :valor)

        retorno = %{
          mensagem: "Total durante todo o período",
          operacao: operacao,
          resultado: resultado
        }

        {:ok, retorno}
    end
  end

  defp validar_data(data) do
    case NaiveDateTime.from_iso8601(data) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
