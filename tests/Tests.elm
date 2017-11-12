module Tests exposing (..)

import Array exposing (Array)
import Expect exposing (Expectation)
import Matrix
import MatrixMath
import Test exposing (..)


matrixMathTests =
    describe "MatrixMath"
        [ describe "dot"
            [ test "zero vectors should return 0" <|
                \_ ->
                    let
                        a =
                            Array.fromList [ 0, 0, 0 ]

                        b =
                            Array.fromList [ 0, 0, 0 ]
                    in
                    Expect.equal (MatrixMath.dot a b) (Just 0)
            , test "empty vectors should return zero" <|
                \_ ->
                    Expect.equal (MatrixMath.dot Array.empty Array.empty) (Just 0)
            , test "differently-sized vectors should return Nothing" <|
                \_ ->
                    let
                        a =
                            Array.fromList [ 1, 2, 3 ]

                        b =
                            Array.fromList [ 1, 2, 3, 4 ]
                    in
                    Expect.equal (MatrixMath.dot a b) Nothing
            , test "math check" <|
                \_ ->
                    let
                        a =
                            Array.fromList [ 1, 2, 3 ]

                        b =
                            Array.fromList [ 1, 2, 3 ]

                        expected =
                            1 * 1 + 2 * 2 + 3 * 3
                    in
                    Expect.equal (MatrixMath.dot a b) (Just expected)
            ]
        , describe "multiply"
            [ test "mismatched sizes should return Nothing" <|
                \_ ->
                    let
                        width =
                            2

                        height =
                            2

                        default =
                            1

                        a =
                            Matrix.repeat width height default

                        b =
                            Array.fromList [ 1, 2, 3 ]
                    in
                    Expect.equal (MatrixMath.multiply a b) Nothing
            , test "matched sizes should return Just <something>" <|
                \_ ->
                    let
                        width =
                            2

                        height =
                            2

                        default =
                            1

                        a =
                            Matrix.repeat width height default

                        b =
                            Array.fromList [ 1, 2 ]

                        expected =
                            Array.fromList [ 3, 3 ]
                    in
                    Expect.equal (MatrixMath.multiply a b) (Just expected)
            , test "3x3 * 3x1" <|
                \_ ->
                    let
                        maybeA =
                            Matrix.fromList
                                [ [ 1, 2, 3 ]
                                , [ 4, 5, 6 ]
                                , [ 7, 8, 9 ]
                                ]

                        b =
                            Array.fromList [ 1, 2, 3 ]

                        expected =
                            Array.fromList
                                [ 14, 32, 50 ]

                        a =
                            case maybeA of
                                Just mat ->
                                    mat

                                _ ->
                                    Debug.crash "invalid a in test" Matrix.empty
                    in
                    Expect.equal (MatrixMath.multiply a b) (Just expected)
            ]
        , describe "test getRows"
            [ test "empty matrix should return empty list" <|
                \_ ->
                    Expect.equal (MatrixMath.getRows Matrix.empty) []
            , test "single row" <|
                \_ ->
                    Expect.equal (MatrixMath.getRows (Matrix.repeat 3 1 1)) [ Array.fromList [ 1, 1, 1 ] ]
            , test "multiple rows" <|
                \_ ->
                    Expect.equal (MatrixMath.getRows (Matrix.repeat 3 2 1)) [ Array.fromList [ 1, 1, 1 ], Array.fromList [ 1, 1, 1 ] ]
            ]
        ]


suite : Test
suite =
    describe "all tests"
        [ matrixMathTests
        ]
