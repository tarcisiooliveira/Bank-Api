defmodule BankApiWeb.ReportView do
  use BankApiWeb, :view

  def render(
        "reports.json",
        %{result: result} = _params
      ) do

    %{
      result: result
    }
  end

  def render(
        "show.json",
        params
      ) do

    %{
      result: params
    }
  end
end
