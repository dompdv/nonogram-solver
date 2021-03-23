defmodule NonosolverTest do
  use ExUnit.Case
  doctest Nonosolver
  import Nonosolver

  test "Vide 5,5 Scenario 1" do
    clues = [
      {:row, 0, [3]},
      {:row, 1, [1, 1]},
      {:row, 2, [1, 3]},
      {:row, 3, [1, 1]},
      {:row, 4, [3]},
      {:col, 0, [3]},
      {:col, 1, [1, 1]},
      {:col, 2, [1, 1, 1]},
      {:col, 3, [1, 1, 1]},
      {:col, 4, [3]}
    ]

    solution = launch_solve(5, List.duplicate(List.duplicate(0, 5), 5), clues)

    assert solution == [
             [0, 1, 1, 1, 0],
             [1, 0, 0, 0, 1],
             [1, 0, 1, 1, 1],
             [1, 0, 0, 0, 1],
             [0, 1, 1, 1, 0]
           ]
  end

  test "Vide 5,5 Scenario 2" do
    clues = [
      {:row, 0, [1]},
      {:row, 1, [2, 1]},
      {:row, 2, [2, 1]},
      {:row, 3, [1]},
      {:row, 4, [4]},
      {:col, 0, [3]},
      {:col, 1, [2, 1]},
      {:col, 2, [2, 1]},
      {:col, 3, [1]},
      {:col, 4, [2]}
    ]

    solution = launch_solve(5, List.duplicate(List.duplicate(0, 5), 5), clues)

    assert solution ==
             [
               [0, 0, 1, 0, 0],
               [0, 1, 1, 0, 1],
               [1, 1, 0, 0, 1],
               [1, 0, 0, 0, 0],
               [1, 1, 1, 1, 0]
             ]
  end

  test "Parsemé 10,10 Scenario 1" do
    clues = [
      {:row, 0, [4]},
      {:row, 1, [3, 2]},
      {:row, 2, [2, 4, 2]},
      {:row, 3, [1, 1, 2, 1, 1]},
      {:row, 4, [6, 1]},
      {:row, 5, [1, 2, 2, 1]},
      {:row, 6, [4, 1]},
      {:row, 7, [1, 2, 2]},
      {:row, 8, [2, 2]},
      {:row, 9, [6]},
      {:col, 0, [2, 1, 1]},
      {:col, 1, [2, 1]},
      {:col, 2, [1, 3, 2]},
      {:col, 3, [3, 3, 1]},
      {:col, 4, [1, 3, 2, 1]},
      {:col, 5, [1, 3, 2, 1]},
      {:col, 6, [1, 1, 3, 1]},
      {:col, 7, [1, 3, 2]},
      {:col, 8, [2, 2]},
      {:col, 9, [6]}
    ]

    matrix = [
      [0, 0, -1, 0, 0, 0, 0, -1, -1, -1],
      [-1, 0, 0, 0, -1, -1, -1, 0, 0, -1],
      [0, 0, -1, 0, 0, 0, 0, -1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, -1, 0],
      [0, 0, 0, 0, -1, -1, 0, 0, -1, 0],
      [0, 0, -1, 0, 0, 0, 0, 0, 0, 0],
      [0, -1, 0, -1, 0, 0, 0, 0, 0, 0],
      [-1, 0, 0, -1, 0, 0, 0, 0, 0, 0],
      [-1, -1, 0, 0, 0, 0, 0, 0, 0, 0]
    ]

    solution = launch_solve(10, matrix, clues)

    assert solution == [
             [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
             [0, 1, 1, 1, 0, 0, 0, 1, 1, 0],
             [1, 1, 0, 1, 1, 1, 1, 0, 1, 1],
             [1, 0, 1, 0, 1, 1, 0, 1, 0, 1],
             [0, 0, 1, 1, 1, 1, 1, 1, 0, 1],
             [1, 0, 1, 1, 0, 0, 1, 1, 0, 1],
             [0, 0, 0, 1, 1, 1, 1, 0, 0, 1],
             [1, 0, 0, 0, 1, 1, 0, 0, 1, 1],
             [0, 1, 1, 0, 0, 0, 0, 1, 1, 0],
             [0, 0, 1, 1, 1, 1, 1, 1, 0, 0]
           ]
  end

  test "Validate matrix_to_map" do
    assert Nonosolver.matrix_to_map([[1, 2], [3, 4]]) == %{
             {0, 0} => 1,
             {0, 1} => 2,
             {1, 0} => 3,
             {1, 1} => 4
           }

    assert Nonosolver.matrix_to_map([[1, 2, 3], [4, 5, 6], [7, 8, 9]]) == %{
             {0, 0} => 1,
             {0, 1} => 2,
             {1, 0} => 4,
             {1, 1} => 5,
             {0, 2} => 3,
             {1, 2} => 6,
             {2, 0} => 7,
             {2, 1} => 8,
             {2, 2} => 9
           }
  end

  test "Validate Scan function" do
    assert Nonosolver.scan([0, 1, 1, 0, 1]) == [2, 1]
    assert Nonosolver.scan([]) == []
    assert Nonosolver.scan([0, 0, 0]) == []
    assert Nonosolver.scan([1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1]) == [3, 2, 2, 1, 1]
    assert Nonosolver.scan([1, 1, 1, 1, 1, 1, 1, 1, 1]) == [9]
  end

  test "Validate Preprocess function" do
    assert Nonosolver.pre_process_number(1, 4) == {[1], [0, 0, 0, 1]}
    assert Nonosolver.pre_process_number(2, 4) == {[1], [0, 0, 1, 0]}
    assert Nonosolver.pre_process_number(4, 4) == {[1], [0, 1, 0, 0]}
    assert Nonosolver.pre_process_number(8, 4) == {[1], [1, 0, 0, 0]}
    assert Nonosolver.pre_process_number(9, 4) == {[1, 1], [1, 0, 0, 1]}
    assert Nonosolver.pre_process_number(255, 8) == {[8], [1, 1, 1, 1, 1, 1, 1, 1]}
  end

  test "Validate precompute_clue_possibilities" do
    assert Nonosolver.precompute_clue_possibilities(1) == %{[] => [[0]], [1] => [[1]]}

    assert Nonosolver.precompute_clue_possibilities(2) == %{
             [] => [[0, 0]],
             [1] => [[0, 1], [1, 0]],
             [2] => [[1, 1]]
           }

    assert Nonosolver.precompute_clue_possibilities(3) ==
             %{
               [] => [[0, 0, 0]],
               [1] => [[0, 0, 1], [0, 1, 0], [1, 0, 0]],
               [2] => [[0, 1, 1], [1, 1, 0]],
               [1, 1] => [[1, 0, 1]],
               [3] => [[1, 1, 1]]
             }

    total_count =
      Nonosolver.precompute_clue_possibilities(15)
      |> Enum.map(fn {_, l} -> Enum.count(l) end)
      |> Enum.sum()

    assert total_count == trunc(:math.pow(2, 15))
  end

  test "Validate Match" do
    match_all = [0, 0, 0, 0]
    assert Nonosolver.match([1, 1, 0, 0], match_all)
    assert Nonosolver.match([0, 1, 0, 1], match_all)

    assert not Nonosolver.match([1, 1, 0, 0], [-1, 1, 0, 0])
    assert Nonosolver.match([0, 1, 0, 0], [-1, 1, 0, 0])

    assert Nonosolver.match([1, 0, 1, 1], [1, -1, 1, 1])
    assert not Nonosolver.match([1, 0, 1, 1], [1, -1, 1, -1])
  end

  test "Validate inter_hypothesis" do
    assert Nonosolver.inter_hypothesis([[1, 1], [0, 1]]) == [0, 1]
    assert Nonosolver.inter_hypothesis([[1, 0], [0, 1]]) == [0, 0]
    assert Nonosolver.inter_hypothesis([[1, 1, 0, 1], [1, 0, 0, 1], [0, 0, 0, 1]]) == [0, 0, 0, 1]
  end
end
