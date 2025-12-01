"""
encode.py
Lee un fichero domXX.txt (rejilla ASCII del problema de taxis)
y produce domain.lp con SOLO hechos y definiciones de constantes.

Uso:
  python3 encode.py dom__.txt domain__.lp
"""

import sys
import os

def read_grid(path):
    """Lee el fichero de dominio y devuelve una lista de líneas sin saltos."""
    with open(path, "r", encoding="utf-8") as f:
        lines = [line.rstrip("\n") for line in f]

    # Eliminar posibles líneas vacías al final
    lines = [ln for ln in lines if ln.strip() != ""]

    if not lines:
        raise AssertionError("El archivo está vacío")

    # Comprobar que todas las filas tienen la misma longitud (rejilla rectangular)
    n_rows = len(lines)
    n_cols = len(lines[0])
    for i, row in enumerate(lines):
        if len(row) != n_cols:
            raise AssertionError(
                f"Fila {i} tiene longitud {len(row)} y se esperaba {n_cols}"
            )

    return lines, n_rows, n_cols

def encode_to_facts(lines, n_rows, n_cols):
    """
    Recorre la rejilla y construye una lista de hechos ASP (strings).
    Convención de índices: filas 0..n_rows-1, columnas 0..n_cols-1.
    """
    facts = []

    # Tamaño del mapa
    facts.append(f"rows({n_rows}).")
    facts.append(f"cols({n_cols}).")

    # Colecciones auxiliares (para evitar duplicados y ordenar)
    cells = []
    buildings = []
    stations = []
    taxis = {}
    passengers = {}

    for r in range(n_rows):
        for c in range(n_cols):
            ch = lines[r][c]
            # Toda posición es una celda de la rejilla
            cells.append((r, c))

            if ch == "#":
                buildings.append((r, c))
            elif ch == "X":
                stations.append((r, c))
            elif ch.isdigit():
                # Taxis: '1'..'9'
                t = int(ch)
                taxis[t] = (r, c)
            elif ch.isalpha():
                # Pasajeros: 'a'..'z' (supondremos siempre minúsculas)
                p = ch
                passengers[p] = (r, c)
            else:
                # '.' u otros símbolos, de momento los ignoramos (solo celda vacía)
                pass

    # Hechos de celdas
    for (r, c) in sorted(cells):
        facts.append(f"cell({r},{c}).")

    # Hechos de edificios
    for (r, c) in sorted(buildings):
        facts.append(f"building({r},{c}).")

    # Hechos de estaciones
    for (r, c) in sorted(stations):
        facts.append(f"station({r},{c}).")

    # Hechos de taxis y sus posiciones iniciales
    for t in sorted(taxis.keys()):
        (r, c) = taxis[t]
        facts.append(f"taxi({t}).")
        facts.append(f"taxi_pos({t},{r},{c}).")

    # Hechos de pasajeros y sus posiciones iniciales
    for p in sorted(passengers.keys()):
        (r, c) = passengers[p]
        facts.append(f"passenger({p}).")
        facts.append(f"passenger_pos({p},{r},{c}).")

    return facts

def main():
    if len(sys.argv) != 3:
        print("Uso: python3 encode.py domXX.txt domain.lp")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]

    # 1) Leer rejilla
    lines, n_rows, n_cols = read_grid(in_path)

    # 2) Construir hechos ASP
    facts = encode_to_facts(lines, n_rows, n_cols)

    # 3) Determinar carpeta 'facts' al nivel del proyecto (a la altura de extaxi)
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    facts_dir = os.path.join(repo_root, "facts")
    os.makedirs(facts_dir, exist_ok=True)

    # Usar el nombre de archivo solicitado pero dentro de facts/
    out_basename = os.path.basename(out_path)
    dest_path = os.path.join(facts_dir, out_basename)

    # 4) Escribir domain.lp dentro de facts/
    with open(dest_path, "w", encoding="utf-8") as f:
        for fact in facts:
            f.write(fact + "\n")

    print(f"[encode] OK → {dest_path} con {len(facts)} hechos.")


if __name__ == "__main__":
    main()