defmodule PhoenixLiveviewDemo.Repo.Migrations.CreateMetrics do
  use Ecto.Migration

  def change do
    create table(:metrics) do
      add :cpu_usage, :float, null: false
      add :memory_usage, :float, null: false
      add :active_connections, :integer, null: false
      add :response_time, :float, null: false
      add :throughput, :float, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:metrics, [:inserted_at])
  end
end
