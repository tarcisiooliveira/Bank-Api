defmodule BankApi.Handle.Report.HandleReportAdmin do
  @moduledoc """
    This Module generate manipulate all Report request than return result.
  """

  alias BankApi.Schemas.{Transaction, Account, Operation}
  alias BankApi.Repo
  import Ecto.Query

  def report(%{"operation" => operation, "period" => "month", "month" => month}) do
    date_time = DateTime.utc_now()

    start_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        String.to_integer(month),
        1,
        0,
        0,
        0,
        {0, 0}
      )

    end_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        String.to_integer(month),
        Calendar.ISO.days_in_month(date_time.year, String.to_integer(month)),
        23,
        59,
        59,
        {99999, 6}
      )

    query =
      from t in Transaction,
        join: o in Operation,
        on: o.id == t.operation_id,
        where:
          t.inserted_at >= ^start_day and
            t.inserted_at <= ^end_day and
            ^operation == o.operation_name,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total in current month by operation.",
          operation: operation,
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total in current month by operation.",
          operation: operation,
          result: result
        }

        {:ok, return}
    end
  end

  def report(%{"period" => "month", "month" => month}) do
    date_time = DateTime.utc_now()

    start_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        String.to_integer(month),
        1,
        0,
        0,
        0,
        {0, 0}
      )

    end_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        String.to_integer(month),
        Calendar.ISO.days_in_month(date_time.year, String.to_integer(month)),
        23,
        59,
        59,
        {99999, 6}
      )

    query =
      from t in Transaction,
        where:
          t.inserted_at >= ^start_day and
            t.inserted_at <= ^end_day,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total in current month by all operations.",
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total in current month by all operations.",
          result: result
        }

        {:ok, return}
    end
  end

  def report(%{"operation" => operation, "period" => "year", "year" => year}) do
    start_day =
      Calendar.ISO.naive_datetime_to_string(
        String.to_integer(year),
        1,
        1,
        0,
        0,
        0,
        {0, 0}
      )

    end_day =
      Calendar.ISO.naive_datetime_to_string(
        String.to_integer(year),
        12,
        31,
        23,
        59,
        59,
        {99999, 6}
      )

    query =
      from t in Transaction,
        join: o in Operation,
        on: o.id == t.operation_id,
        where:
          t.inserted_at >= ^start_day and
            t.inserted_at <= ^end_day and
            ^operation == o.operation_name,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total in current year by operations.",
          operation: operation,
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total in current year by operations.",
          operation: operation,
          result: result
        }

        {:ok, return}
    end
  end

  def report(%{"period" => "year", "year" => year}) do
    start_day =
      Calendar.ISO.naive_datetime_to_string(
        String.to_integer(year),
        1,
        1,
        0,
        0,
        0,
        {0, 0}
      )

    end_day =
      Calendar.ISO.naive_datetime_to_string(
        String.to_integer(year),
        12,
        31,
        23,
        59,
        59,
        {99999, 6}
      )

    query =
      from t in Transaction,
        where:
          t.inserted_at >= ^start_day and
            t.inserted_at <= ^end_day,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total in current year by all operations.",
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total in current year by all operations.",
          result: result
        }

        {:ok, return}
    end
  end

  def report(%{"operation" => operation, "period" => "today"}) do
    date_time = DateTime.utc_now()

    start_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        date_time.month,
        date_time.day,
        0,
        0,
        0,
        {0, 0}
      )

    end_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        date_time.month,
        date_time.day,
        23,
        59,
        59,
        {99999, 6}
      )

    query =
      from t in Transaction,
        join: o in Operation,
        on: o.id == t.operation_id,
        where:
          t.inserted_at >= ^start_day and
            t.inserted_at <= ^end_day,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total in current day by operation.",
          operation: operation,
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total in current day by operation.",
          operation: operation,
          result: result
        }

        {:ok, return}
    end
  end
  def report(%{ "period" => "today"}) do
    date_time = DateTime.utc_now()

    start_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        date_time.month,
        date_time.day,
        0,
        0,
        0,
        {0, 0}
      )

    end_day =
      Calendar.ISO.naive_datetime_to_string(
        date_time.year,
        date_time.month,
        date_time.day,
        23,
        59,
        59,
        {99999, 6}
      )

    query =
      from t in Transaction,
        where:
          t.inserted_at >= ^start_day and
            t.inserted_at <= ^end_day,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total in current day by all operation.",
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total in current day by all operation.",
          result: result
        }

        {:ok, return}
    end
  end

  def report(%{"operation" => operation, "period" => "all"}) do
    query =
      from t in Transaction,
        join: o in Operation,
        on: t.operation_id == o.id,
        where: o.operation_name == ^operation,
        select: [t.value]

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total for the entire period.",
          operation: operation,
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total for the entire period.",
          operation: operation,
          result: result
        }

        {:ok, return}
    end
  end

  def report(%{"period" => "all"}) do
    query =
      from t in Transaction,
        select: [t.value]

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        return = %{
          message: "Total moved for the entire period.",
          result: 0
        }

        {:ok, return}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        return = %{
          message: "Total moved for the entire period.",
          result: result
        }

        {:ok, return}
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

    case valid_accounts?(from_account_id, to_account_id) &&
           validate_dates(initial_date, final_date) do
      true ->
        query =
          from t in Transaction,
            join: o in Operation,
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
              message: "Total in determineted period for determineted between tow Accounts.",
              operation: operation,
              result: 0
            }

            {:ok, return}

          _ ->
            result = Repo.aggregate(query, :sum, :value)

            return = %{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              message: "Total in determineted period for determineted between tow Accounts.",
              operation: operation,
              result: result
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           message: "Invalid data. Verify Account ID, Date or Operation."
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
           validate_dates(initial_date, final_date) do
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
              message: "Total in determineted period for determineted Account.",
              operation: operation,
              result: 0
            }

            {:ok, return}

          _ ->
            result = Repo.aggregate(query, :sum, :value)

            return = %{
              from_account_id: from_account_id,
              message: "Total in determineted period for determineted Account.",
              operation: operation,
              result: result
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           message: "Invalid data. Verify Account ID, Date or Operation."
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
              message: "Total in determineted period between all Accounts.",
              operation: operation,
              result: 0
            }

            {:ok, return}

          _ ->
            result = Repo.aggregate(query, :sum, :value)

            return = %{
              message: "Total in determineted period between all Accounts.",
              operation: operation,
              result: result
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           message: "Invalid data. Verify Date or Operation."
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
          message: "Total trasfered by determineted Account.",
          operation: operation,
          result: result
        }

        {:ok, return}

      false ->
        {:error,
         %{
           message: "Invalid data. Verify Account ID ou Operation."
         }}
    end
  end

  defp validate_date(date) do
    case NaiveDateTime.from_iso8601(date) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp validate_dates(start_date, final_date) do
    with {:ok, _} <- NaiveDateTime.from_iso8601(start_date),
         {:ok, _} <- NaiveDateTime.from_iso8601(final_date) do
      true
    end
  end

  def valid_account?(account_id) do
    case Repo.get_by(Account, id: account_id) do
      %Account{} -> true
      _ -> false
    end
  end

  def valid_accounts?(from_account_id, to_account_id) do
    with {:ok, %Account{}} <- Repo.get_by(Account, id: from_account_id),
         {:ok, %Account{}} <- Repo.get_by(Account, id: to_account_id) do
      true
    end
  end
end
