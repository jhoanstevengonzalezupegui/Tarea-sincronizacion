defmodule LavaderoSincronizado do

  def main do
    IO.puts("=== Iniciando Lavadero de Carros ===")
    espacios_disponibles = 2

    # 1. Iniciamos el semáforo
    semaforo_pid = iniciar_semaforo(espacios_disponibles)

    # 2. Simula la llegada de 5 carros poco a poco
    Enum.each(1..5, fn id ->
      simular_carro(id, semaforo_pid)
      Process.sleep(500) # Espera medio segundo entre cada llegada
    end)

    # Pausa el programa principal para que no se cierre de golpe
    Process.sleep(12000)
    IO.puts("=== Lavadero Cerrado ===")
  end

  #  MÉTODOS

  defp iniciar_semaforo(espacios) do
    spawn(fn -> bucle_semaforo(espacios, []) end)
  end

  defp bucle_semaforo(espacios, cola) do
    receive do
      {:solicitar_entrada, pid_del_carro} ->
        if espacios > 0 do
          send(pid_del_carro, :luz_verde)
          bucle_semaforo(espacios - 1, cola)
        else
          IO.puts("🟡 Aforo lleno. Enviando a cola de prioridad.")
          bucle_semaforo(espacios, cola ++ [pid_del_carro])
        end

      :salir ->
        if length(cola) > 0 do
          [primer_carro | resto_cola] = cola
          send(primer_carro, :luz_verde)
          bucle_semaforo(espacios, resto_cola)
        else
          bucle_semaforo(espacios + 1, cola)
        end
    end
  end

  defp simular_carro(id, semaforo_pid) do
    spawn(fn ->
      IO.puts("🚗 Carro #{id} llega y solicita turno...")
      send(semaforo_pid, {:solicitar_entrada, self()})

      receive do
        :luz_verde ->
          IO.puts("🟢 Carro #{id} entra a lavarse.")
          Process.sleep(2000)
          IO.puts("🔴 Carro #{id} terminó. Liberando espacio...")
          send(semaforo_pid, :salir)
      end
    end)
  end
end

LavaderoSincronizado.main()
