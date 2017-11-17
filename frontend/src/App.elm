module Main exposing (..)

import Html
import Matrix exposing (Matrix, loc)
import Mouse
import Types exposing (Model, Msg(..))
import View
import WebSocket


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = View.root
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    let
        image =
            Matrix.square 28 (\_ -> 0)
    in
    ( { image = image
      , drawing = False
      , previousDrawn = Nothing
      , predicted = Nothing
      , serverAddress = "localhost:8765"
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseOverCell row col ->
            if model.drawing && Just ( row, col ) /= model.previousDrawn then
                let
                    delta =
                        List.range -1 1

                    neighbors =
                        -- this functional soup just makes a list of locations of
                        -- cells adjacent to the current cell
                        delta
                            |> List.concatMap (\i -> List.map ((,) i) delta)
                            |> List.filter ((/=) ( 0, 0 ))
                            |> List.map (\( dr, dc ) -> ( dr + row, dc + col ))
                            |> List.map (\( r, c ) -> loc r c)

                    -- Add a bit to each neighbor, which results in lighter edges
                    -- around each line. This more closely resembles the original
                    -- MNIST data than solid colors.
                    colorNeighbors : Matrix Float -> List Matrix.Location -> Matrix Float
                    colorNeighbors image neighbors =
                        case neighbors of
                            [] ->
                                image

                            location :: tail ->
                                colorNeighbors (Matrix.update location (\v -> min 1 (v + 0.5)) image) tail

                    newImage =
                        colorNeighbors model.image neighbors
                            |> Matrix.set (loc row col) 1.0
                in
                ( { model
                    | image = newImage
                    , previousDrawn = Just ( row, col )
                  }
                , newImage |> Matrix.toList |> toString |> WebSocket.send model.serverAddress
                )
            else
                ( model, Cmd.none )

        StartDrawing ->
            ( { model | drawing = True }, Cmd.none )

        StopDrawing ->
            ( { model | drawing = False }, Cmd.none )

        Clear ->
            let
                ( rows, cols ) =
                    ( Matrix.rowCount model.image, Matrix.colCount model.image )

                newImage =
                    Matrix.matrix rows cols (\_ -> 0)
            in
            ( { model | image = newImage }, Cmd.none )

        NewSocketMessage message ->
            let
                newPrediction =
                    Result.toMaybe (String.toInt message)
            in
            ( { model | predicted = newPrediction }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (\_ -> StartDrawing)
        , Mouse.ups (\_ -> StopDrawing)
        , WebSocket.listen model.serverAddress NewSocketMessage
        ]
