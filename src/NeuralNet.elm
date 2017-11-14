module NeuralNet exposing (ActivationFunc(..), Net, calculateActivation, initialize, predict, weightMatrixSizeHelper)

{-| This module is designed to make it simple to take the weights and biases
from a network that has already been trained, and use them to make predictions.
-}

import Array exposing (Array)
import Matrix exposing (Matrix)
import MatrixMath


type ActivationFunc
    = ReLu
    | Identity
    | Sigmoid


type alias Net a =
    { biases : List (Array a)
    , weights : List (Matrix a)
    , activation : ActivationFunc
    }


{-| Predict neural net output for given input
-}
predict : Net Float -> Array Float -> Maybe (Array Float)
predict net input =
    let
        wb =
            List.map2 (,) net.weights net.biases

        activations =
            List.foldl (calculateActivation net.activation) (Just input) wb
    in
    activations


{-| Create a neural network with all weights and biases set to the same value.
Since training is not implemented yet, this is mostly just useful for testing.
-}
initialize : List Int -> a -> ActivationFunc -> Net a
initialize layers initialValue activation =
    case layers of
        [] ->
            Net [] [] activation

        h :: tail ->
            let
                weights =
                    weightMatrixSizeHelper layers []
                        |> List.map (\( c, r ) -> Matrix.matrix r c (\_ -> initialValue))

                biases =
                    List.map (\i -> Array.repeat i initialValue) tail
            in
            { biases = biases
            , weights = weights
            , activation = activation
            }


weightMatrixSizeHelper : List Int -> List ( Int, Int ) -> List ( Int, Int )
weightMatrixSizeHelper layers matrixSizes =
    case layers of
        a :: b :: tail ->
            weightMatrixSizeHelper (b :: tail) (List.append matrixSizes [ ( a, b ) ])

        [] ->
            matrixSizes

        h :: [] ->
            matrixSizes


calculateActivation : ActivationFunc -> ( Matrix Float, Array Float ) -> Maybe (Array Float) -> Maybe (Array Float)
calculateActivation activationFunc ( weights, biases ) prevActivations =
    let
        f =
            case activationFunc of
                ReLu ->
                    max 0

                Identity ->
                    identity

                Sigmoid ->
                    \x -> 1 / (1 + e ^ (-1 * x))
    in
    prevActivations
        |> Maybe.andThen (MatrixMath.multiply weights)
        |> Maybe.map (MatrixMath.arrayMap2 (+) biases)
        |> Maybe.map (Array.map f)
