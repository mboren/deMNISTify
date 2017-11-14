module MatrixMath exposing (..)

{-| This module adds some helper functions for working with the Matrix type
from eeue56/elm-flat-matrix. These will mostly be used for Neural network
calculations.
-}

import Array exposing (Array)
import Matrix exposing (Matrix)


{-| Like List.map2, but with Arrays.
-}
arrayMap2 : (a -> b -> result) -> Array a -> Array b -> Array result
arrayMap2 f a b =
    let
        la =
            Array.toList a

        lb =
            Array.toList b
    in
    List.map2 f la lb
        |> Array.fromList


{-| Dot product of 2 vectors.
Returns Nothing if lengths aren't equal.
-}
dot : Array number -> Array number -> Maybe number
dot a b =
    if Array.length a == Array.length b then
        arrayMap2 (*) a b
            |> Array.foldr (+) 0
            |> Just
    else
        Nothing


{-| Multiply matrix a by column-vector b.
If width of a is not equal to length of b, return Nothing.
-}
multiply : Matrix number -> Array number -> Maybe (Array number)
multiply a b =
    if Matrix.colCount a == Array.length b then
        let
            dotProducts =
                List.map (dot b) (getRows a)
        in
        if List.all (\i -> i /= Nothing) dotProducts then
            -- dot only returns Nothing when given incompatible lengths,
            -- and we've already checked for that, so filterMap will unwrap
            -- the Maybes without removing any values.
            dotProducts
                |> List.filterMap identity
                |> Array.fromList
                |> Just
        else
            Nothing
    else
        Nothing


{-| Split rows of matrix up into a list of arrays.
This is a handy thing for mapping over.
-}
getRows : Matrix a -> List (Array a)
getRows matrix =
    Array.toList matrix


{-| Get center of mass of a matrix. This is used for centering
the image before it is classified.
-}
centerOfMass : Matrix Float -> ( Float, Float )
centerOfMass image =
    if 0 == Matrix.rowCount image then
        ( 0, 0 )
    else
        let
            weights ( ( row, col ), value ) =
                let
                    rowW =
                        toFloat row * value

                    colW =
                        toFloat col * value
                in
                ( rowW, colW )

            nonZeroCells =
                Matrix.mapWithLocation (,) image
                    |> Matrix.flatten
                    |> List.filter (\( _, v ) -> v > 0.0)

            totalWeight =
                nonZeroCells
                    |> List.map Tuple.second
                    |> List.sum

            ( rowWeight, colWeight ) =
                nonZeroCells
                    |> List.map weights
                    |> List.unzip
                    |> Tuple.mapFirst List.sum
                    |> Tuple.mapSecond List.sum
        in
        ( rowWeight / totalWeight, colWeight / totalWeight )


shift : Matrix Float -> Float -> Float -> Matrix Float
shift image dr dc =
    let
        f ( r, c ) v =
            let
                ( drFrac, dcFrac ) =
                    ( dr - toFloat (floor dr), dc - toFloat (floor dc) )

                aDist =
                    sqrt (dcFrac * dcFrac + drFrac * drFrac)

                bDist =
                    sqrt ((1 - dcFrac) * (1 - dcFrac) + (1 - drFrac) * (1 - drFrac))

                totalDist =
                    aDist + bDist

                aWeight =
                    aDist / totalDist

                bWeight =
                    bDist / totalDist

                a =
                    Matrix.get (Matrix.loc (r - floor dr) (c - floor dc)) image
                        |> Maybe.withDefault 0.0

                b =
                    Matrix.get (Matrix.loc (r - ceiling dr) (c - ceiling dc)) image
                        |> Maybe.withDefault 0.0
            in
            a * aWeight + b * bWeight
    in
    Matrix.mapWithLocation f image


center : Matrix Float -> Matrix Float
center image =
    let
        ( cmCol, cmRow ) =
            centerOfMass image

        ( cRow, cCol ) =
            ( toFloat (Matrix.rowCount image) / 2, toFloat (Matrix.colCount image) / 2 )

        ( dr, dc ) =
            ( cRow - cmRow, cCol - cmCol )
    in
    shift image dr dc
