module Tests exposing (..)

import Array exposing (Array)
import Expect exposing (Expectation)
import Matrix
import MatrixMath
import NeuralNet exposing (ActivationFunc(..))
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
                        size =
                            2

                        default =
                            1

                        a =
                            Matrix.square size (\_ -> default)

                        b =
                            Array.fromList [ 1, 2, 3 ]
                    in
                    Expect.equal (MatrixMath.multiply a b) Nothing
            , test "matched sizes should return Just <something>" <|
                \_ ->
                    let
                        size =
                            2

                        default =
                            1

                        a =
                            Matrix.square size (\_ -> default)

                        b =
                            Array.fromList [ 1, 2 ]

                        expected =
                            Array.fromList [ 3, 3 ]
                    in
                    Expect.equal (MatrixMath.multiply a b) (Just expected)
            , test "3x3 * 3x1" <|
                \_ ->
                    let
                        a =
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
                    in
                    Expect.equal (MatrixMath.multiply a b) (Just expected)
            ]
        , describe "test getRows"
            [ test "empty matrix should return empty list" <|
                \_ ->
                    Expect.equal (MatrixMath.getRows (Matrix.fromList [])) []
            , test "single row" <|
                \_ ->
                    Expect.equal (MatrixMath.getRows (Matrix.fromList [ [ 1, 1, 1 ] ])) [ Array.fromList [ 1, 1, 1 ] ]
            , test "multiple rows" <|
                \_ ->
                    Expect.equal (MatrixMath.getRows (Matrix.fromList [ [ 1, 1, 1 ], [ 1, 1, 1 ] ])) [ Array.fromList [ 1, 1, 1 ], Array.fromList [ 1, 1, 1 ] ]
            ]
        ]


neuralNetTests =
    describe "NeuralNet tests"
        [ describe "initialize"
            [ test "empty layers list should result in empty weights and biases" <|
                \_ ->
                    Expect.equal (NeuralNet.initialize [] 0 Identity) { biases = [], weights = [], activation = Identity }
            , test "basic example" <|
                \_ ->
                    let
                        weightMatrixSizes =
                            [ ( 2, 3 ), ( 3, 2 ) ]

                        weights =
                            weightMatrixSizes
                                |> List.map (\( c, r ) -> Matrix.matrix r c (\_ -> 0))
                    in
                    Expect.equal (NeuralNet.initialize [ 2, 3, 2 ] 0 Identity) { biases = [ Array.repeat 3 0, Array.repeat 2 0 ], weights = weights, activation = Identity }
            ]
        , describe "weightMatrixSizeHelper"
            [ test "empty inputs should result in empty list" <|
                \_ ->
                    Expect.equal (NeuralNet.weightMatrixSizeHelper [] []) []
            , test "basic example" <|
                \_ ->
                    Expect.equal (NeuralNet.weightMatrixSizeHelper [ 4, 3, 2 ] []) [ ( 4, 3 ), ( 3, 2 ) ]
            ]
        , describe "feedforward"
            [ test "if input doesn't match first layer size, should return Nothing" <|
                \_ ->
                    let
                        net =
                            { biases = [ Array.repeat 3 1, Array.repeat 2 1 ]
                            , weights =
                                [ ( 2, 3 ), ( 3, 2 ) ]
                                    |> List.map (\( c, r ) -> Matrix.matrix r c (\_ -> 1))
                            , activation = Identity
                            }
                    in
                    Expect.equal (NeuralNet.predict net (Array.fromList [ 1, 1, 1 ])) Nothing
            , test "input matching first layer size should return something" <|
                \_ ->
                    let
                        net =
                            { biases = [ Array.repeat 3 1, Array.repeat 2 1 ]
                            , weights =
                                [ ( 2, 3 ), ( 3, 2 ) ]
                                    |> List.map (\( c, r ) -> Matrix.matrix r c (\_ -> 1))
                            , activation = Identity
                            }
                    in
                    Expect.equal (NeuralNet.predict net (Array.fromList [ 1, 1 ])) (Just (Array.repeat 2 10))
            , test "net with mismatched weights and biases should return Nothing" <|
                \_ ->
                    let
                        net =
                            { biases = [ Array.repeat 2 1, Array.repeat 2 1 ]
                            , weights =
                                [ ( 2, 3 ), ( 3, 2 ) ]
                                    |> List.map (\( c, r ) -> Matrix.matrix r c (\_ -> 1))
                            , activation = Identity
                            }
                    in
                    Expect.equal (NeuralNet.predict net (Array.fromList [ 1, 1 ])) Nothing
            ]
        ]



suite : Test
suite =
    describe "all tests"
        [ matrixMathTests
        , neuralNetTests
        ]
