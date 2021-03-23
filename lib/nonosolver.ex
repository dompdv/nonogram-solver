defmodule Nonosolver do
  def launch_solve(size, matrix, clues) do
    board = matrix_to_map(matrix)
    possibilities = precompute_clue_possibilities(size)
    board = solve(size, possibilities, board, clues, [])
    map_to_matrix(size, board)
  end

  # No more Clues (neither examined nor arcchived)
  def solve(_size, _possibilities, board, [], []), do: board

  # All the clues have been examined one by one. Restart the search with the archived ones
  def solve(size, possibilities, board, [], archived_clues),
    do: solve(size, possibilities, board, Enum.reverse(archived_clues), [])

  # Solves a Nonogram
  # Size = length of the square
  # Possibilities = the precomputed possibility list per Groups
  # Board = the current status of the board : 1 for an occupied cell, -1 for an unoccupied cell, 0 for unknown
  # Clies = liste de {:row ou :col, numéro de la ligne ou de la colonne (de 0 à size-1), [groupes]}. Exemple [{:row, 2, [1,3]}]
  # Archieved_clues = sert d'accumumateur à Clues déjà passées en revue, et qui ne permettent pas de conclure sur la ligne ou la colonne
  def solve(
        size,
        possibilities,
        board,
        [{direction, index, groups} = clue | clues],
        archived_clues
      ) do
    # Récupère la ligne ou la colonne relative à la clue considérée
    line =
      case direction do
        :row -> Enum.map(0..(size - 1), fn c -> Map.get(board, {index, c}) end)
        :col -> Enum.map(0..(size - 1), fn r -> Map.get(board, {r, index}) end)
      end

    # Attention, c'est un point fondamental
    # On filtre toutes les possibilités par rapport à ce qui a déjà été marqué sur le board.
    # Il ne reste donc que les possibilités compatibles avec ce qui est déjà marqué
    # Et on en fait l'intersection.
    checked =
      Enum.filter(Map.get(possibilities, groups), fn e -> match(e, line) end)
      |> inter_hypothesis()

    # Si cette intersection est compatible avec les groups, c'est qu'on a trouvé la solution définitive pour la ligne
    checked_line = scan(checked) == groups

    # Si on a trouvé la solution définitive pour la ligne, cela veut dire que les cellule non marquée sont bien vides
    # et il faut les marquer à -1 plutôt que 0
    checked =
      if checked_line do
        Enum.map(checked, fn c -> if c == 1, do: 1, else: -1 end)
      else
        checked
      end

    # On remplit le board avec la ligne résultante, (ligne ou colonne bien sûr)
    new_board =
      case direction do
        :row ->
          Enum.reduce(0..(size - 1), board, fn c, b ->
            Map.put(b, {index, c}, Enum.at(checked, c))
          end)

        :col ->
          Enum.reduce(0..(size - 1), board, fn r, b ->
            Map.put(b, {r, index}, Enum.at(checked, r))
          end)
      end

    # Si on a une solution définitive pour la ligne, on ne met pas la clue dans les archived.
    # Car on n'aura pas besoin de reconsidérer cette clue
    # Sinon, on le place dans l'archived pour un passage futur
    if checked_line do
      solve(size, possibilities, new_board, clues, archived_clues)
    else
      solve(size, possibilities, new_board, clues, [clue | archived_clues])
    end
  end

  # Transforme une matrice, c'est à dire une liste de listes en une Map dont les clés sont les coordonnées {row, col} et la valeur
  # l'élément de la matrice à ces coordonnées
  def matrix_to_map(m) do
    m
    |> Enum.with_index()
    |> Enum.map(fn {row, r} ->
      Enum.with_index(row)
      |> Enum.map(fn {v, c} -> {{r, c}, v} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def map_to_matrix(size, board) do
    for(r <- 0..(size - 1), c <- 0..(size - 1), do: Map.get(board, {r, c}))
    |> Enum.map(fn c -> if c == 1, do: 1, else: 0 end)
    |> Enum.chunk_every(size)
  end

  # L'idée est de caculer toutes les possibilités correspondant à un liste de groupes
  # Par exemple, pour une ligne de 5,
  # un ensemble de type [1, 3] va donner [1, 0, 1, 1, 1] obligatoirement
  # tandis que [1, 1] va donner [1, 1, 0, 0], [1, 0, 1, 0], [1, 0, 0, 1], [0, 1, 1, 0], [0, 1, 0, 1], [0, 0, 1, 1]
  def precompute_clue_possibilities(square_size) do
    # L'astuce est de faire les choses à l'envers: on va regarder la représentation binaire de tous les nombre de 0 à 2^n-1
    # et, pour chaque nombre, compter les groupes
    Enum.map(
      0..(trunc(:math.pow(2, square_size)) - 1),
      fn n ->
        # transforme un nombre en une liste de 0 et 1 représentant sa forme binaire, puis compter les groupes de 1
        pre_process_number(n, square_size)
      end
    )
    # tranformer en une Map du type liste de groupe -> liste de possibilités
    |> Enum.group_by(fn {k, _} -> k end)
    |> Enum.map(fn {k, l} -> {k, Enum.map(l, fn {_, v} -> v end)} end)
    |> Map.new()
  end

  # A partir d'un nombre, passe à sa représentation binaire de taille 'size ' (size est le nombre de bits)
  # puis compte les groupes de 1
  def pre_process_number(x, size) do
    binary_rep = Integer.to_string(x, 2) |> String.graphemes() |> Enum.map(&String.to_integer/1)
    completed = List.duplicate(0, size - Enum.count(binary_rep)) ++ binary_rep
    # renvoir un couple groupes, représentation binaire
    {scan(completed), completed}
  end

  # Scan
  # A partir d'une liste de 0 et 1, comme [0, 1, 1, 0, 1]
  # renvoie une liste représentant les tailles des groupes de 1 consécutifs
  # [0, 1, 1, 0, 1] -> [2, 1]
  def scan([]), do: []
  def scan(l), do: scan(l, [0])

  # Termine la récursion, en éliminant un éventuel groupe nul en tête
  def scan([], [0 | r_acc]), do: Enum.reverse(r_acc)
  def scan([], acc), do: Enum.reverse(acc)
  # Si l'on rencontre un 0 et qu'un nouveau groupe a été mis dans l'accumumateur, ne rien faire
  def scan([0 | rest], [0 | _] = acc), do: scan(rest, acc)
  # Sinon créer un nouveau groupe à 0
  def scan([0 | rest], [x | r_acc]), do: scan(rest, [0, x | r_acc])
  # Si l'on rencontre un 1, incrémenter le compteur du groupe
  def scan([1 | rest], [x | r_acc]), do: scan(rest, [x + 1 | r_acc])

  # Vérifie si une liste suit un motif
  # Le motif est une liste de 0 -> match tout, 1-> match 1, -1 -> match 0
  def match([], []), do: true

  def match([n | l], [m | p]) do
    cond do
      m == 0 -> match(l, p)
      m == -1 && n == 0 -> match(l, p)
      m == 1 && n == 1 -> match(l, p)
      true -> false
    end
  end

  # Cela revient à faire un && binaire entre toutes les listes
  # Dit autrement, renvoie une liste qui a des 1 à la position où toutes les listes en ont un
  def inter_hypothesis(l) do
    Enum.reduce(l, fn x, acc -> inter_couple(x, acc, []) end)
  end

  def inter_couple([], _, acc), do: Enum.reverse(acc)

  def inter_couple([a | r1], [b | r2], acc) do
    if a == 1 and b == 1,
      do: inter_couple(r1, r2, [1 | acc]),
      else: inter_couple(r1, r2, [0 | acc])
  end
end
