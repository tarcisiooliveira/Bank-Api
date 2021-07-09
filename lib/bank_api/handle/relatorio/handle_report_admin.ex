defmodule BankApi.Handle.Report.HandleReportAdmin do
  alias BankApi.Schemas.{Transaction, Account, Operation}
  alias BankApi.Repo
  import Ecto.Query

  def valid_account?(account_id) do
    case Repo.get_by(Account, id: account_id) do
      %Account{} -> true
      _ -> false
    end
  end

  def report(
        %{
          "initial_date" => initial_date,
          "final_date" => final_date,
          "from_account_id" => from_account_id,
          "to_account_id" => to_account_id,
          "operation" => operation
        } = _params
      ) do
    case valid_account?(from_account_id) &&
           valid_account?(to_account_id) &&
           validate_date(initial_date) &&
           validate_date(final_date) do
      true ->
        query =
          from t in Transaction,
            join: o in Operacao,
            on: o.id == t.operation_id,
            where:
              o.operation_name == ^operation and
                t.to_account_id == ^to_account_id and
                t.from_account_id == ^from_account_id and
                t.inserted_at > ^initial_date and
                t.inserted_at < ^final_date,
            select: t.value

        quantity =
          Repo.all(query)
          |> Enum.count()

        case quantity do
          0 ->
            return = %{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              mensagem: "Total for determineted period for determineted between tow Accounts.",
              operation: operation,
              result: 0
            }

            {:ok, return}

          _ ->
            result = Repo.aggregate(query, :sum, :value)

            return = %{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              mensagem: "Total for determineted period for determineted between tow Accounts.",
              operation: operation,
              result: result
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           mensagem: "Invalid data. Verify Account ID, Date or Operation."
         }}
    end
  end

  def report(%{
        "initial_date" => initial_date,
        "final_date" => final_date,
        "from_account_id" => from_account_id,
        "operation" => operation
      }) do
    case valid_account?(from_account_id) &&
           validate_date(initial_date) &&
           validate_date(final_date) do
      true ->
        query =
          from t in Transaction,
            join: c in Account,
            join: o in Operation,
            on: o.id == t.operation_id,
            on: t.from_account_id == c.id,
            where:
              t.from_account_id == ^from_account_id and t.inserted_at >= ^initial_date and
                t.inserted_at <= ^final_date and o.operation_name == ^operation,
            select: t.value

        quantity =
          Repo.all(query)
          |> Enum.count()

        case quantity do
          0 ->
            return = %{
              from_account_id: from_account_id,
              mensagem: "Total for determineted period for determineted Account.",
              operation: operation,
              result: 0
            }

            {:ok, return}

          _ ->
            result = Repo.aggregate(query, :sum, :value)

            return = %{
              from_account_id: from_account_id,
              mensagem: "Total for determineted period for determineted Account.",
              operation: operation,
              result: result
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           mensagem: "Invalid data. Verify Account ID, Date or Operation."
         }}
    end
  end

  def report(%{
        "initial_date" => initial_date,
        "final_date" => final_date,
        "operation" => operation
      }) do
    case validate_date(initial_date) &&
           validate_date(final_date) do
      true ->
        query =
          from t in Transaction,
            join: o in Operation,
            on: o.id == t.operation_id,
            where:
              t.inserted_at >= ^initial_date and
                t.inserted_at <= ^final_date and
                o.operation_name == ^operation,
            select: t.value

        quantity =
          Repo.all(query)
          |> Enum.count()

        case quantity do
          0 ->
            return = %{
              mensagem: "Total for determineted period between all Accounts.",
              operation: operation,
              result: 0
            }

            {:ok, return}

          _ ->
            result = Repo.aggregate(query, :sum, :value)

            return = %{
              mensagem: "Total for determineted period between all Accounts.",
              operation: operation,
              result: result
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           mensagem: "Invalid data. Verify Date or Operation."
         }}
    end
  end

  def report(%{"from_account_id" => from_account_id, "operation" => operation}) do
    case valid_account?(from_account_id) do
      true ->
        query =
          from t in Transaction,
            join: c in Account,
            join: o in Operation,
            on: o.id == t.operation_id,
            on: t.from_account_id == c.id,
            where:
              o.operation_name == ^operation and
                t.from_account_id == ^from_account_id,
            select: t.value

        result = Repo.aggregate(query, :sum, :value)

        return = %{
          mensagem: "Total trasfered by determineted Account.",
          operation: operation,
          result: result
        }

        {:ok, return}

      false ->
        {:error,
         %{
           mensagem: "Invalid data. Verify Account ID ou Operation."
         }}
    end
  end

  def report(%{"period" => "all", "operation" => operation}) do
    query =
      from t in Transaction,
        join: o in Operations,
        on: t.operation_id == o.id,
        where: o.operation_name == ^operation,
        select: [t.value]

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          mensagem: "Total for the entire period ",
          operation: operation,
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          mensagem: "Total for the entire period ",
          operation: operation,
          result: result
        }

        {:ok, return}
    end
  end

  defp validate_date(date) do
    case NaiveDateTime.from_iso8601(date) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
