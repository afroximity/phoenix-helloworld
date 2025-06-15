# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoenixLiveviewDemo.Repo.insert!(%PhoenixLiveviewDemo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PhoenixLiveviewDemo.{Repo, Metrics}

# Clear existing metrics
Repo.delete_all(Metrics)

# Insert some initial metrics data
for i <- 1..10 do
  %Metrics{}
  |> Metrics.changeset(%{
    cpu_usage: :rand.uniform() * 100,
    memory_usage: :rand.uniform() * 1000 + 100,
    active_connections: :rand.uniform(100) + 10,
    response_time: :rand.uniform() * 100 + 5,
    throughput: :rand.uniform() * 1000 + 200
  })
  |> Repo.insert!()
  
  # Add a small delay to spread out timestamps
  Process.sleep(100)
end

IO.puts("Seeded #{Repo.aggregate(Metrics, :count, :id)} metrics records")
