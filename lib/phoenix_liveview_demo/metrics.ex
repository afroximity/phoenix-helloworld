defmodule PhoenixLiveviewDemo.Metrics do
  use Ecto.Schema
  import Ecto.Changeset

  schema "metrics" do
    field :cpu_usage, :float
    field :memory_usage, :float
    field :active_connections, :integer
    field :response_time, :float
    field :throughput, :float

    timestamps(type: :utc_datetime)
  end

  def changeset(metric, attrs) do
    metric
    |> cast(attrs, [:cpu_usage, :memory_usage, :active_connections, :response_time, :throughput])
    |> validate_required([:cpu_usage, :memory_usage, :active_connections, :response_time, :throughput])
  end
end
