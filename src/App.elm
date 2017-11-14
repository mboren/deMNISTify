module Main exposing (Model, Msg, init, subscriptions, update, view)

import Array exposing (Array)
import Html exposing (Html, div, text)
import Html.Attributes
import Matrix exposing (Matrix, loc)
import Mouse
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events exposing (onMouseMove)


pxSize =
    10


controlHeight =
    15


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { image : Matrix Float
    , drawing : Bool
    , previousDrawn : Maybe ( Int, Int )
    , predicted : Maybe Int
    }


init : ( Model, Cmd Msg )
init =
    let
        image =
            Matrix.square 28 (\_ -> 0)
    in
    ( Model image False Nothing Nothing, Cmd.none )


type Msg
    = MouseOverCell Int Int
    | StartDrawing
    | StopDrawing
    | Clear


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseOverCell col row ->
            if model.drawing && Just ( col, row ) /= model.previousDrawn then
                let
                    neighbors =
                        []

                    -- Add a bit to each neighbor, which results in lighter edges
                    -- around each line. This more closely resembles the original
                    -- MNIST data than solid colors.
                    colorNeighbors : Matrix Float -> List ( ( Int, Int ), Float ) -> Matrix Float
                    colorNeighbors image neighbors =
                        case neighbors of
                            [] ->
                                image

                            ( ( col, row ), value ) :: tail ->
                                colorNeighbors (Matrix.set (loc row col) (min 1 (value + 0.4)) image) tail

                    newImage =
                        colorNeighbors model.image neighbors
                            |> Matrix.set (loc row col) 1.0

                    newPredicted =
                        recognizeDigit model.image
                in
                ( { model
                    | image = newImage
                    , predicted = newPredicted
                    , previousDrawn = Just ( col, row )
                  }
                , Cmd.none
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

{--
recognizeDigit2 : Net Float -> Matrix Float -> Maybe Int
recognizeDigit2 net image =
    let
        flattened =
            image
                |> MatrixMath.getRows
                |> List.foldl Array.append Array.empty

        output =
            NeuralNet.predict net flattened

        digit =
            case output of
                Nothing ->
                    Nothing

                Just activations ->
                    let
                        greatest =
                            activations |> Array.toList |> List.maximum |> Maybe.withDefault 0
                    in
                    activations
                        |> Array.toIndexedList
                        |> List.filter (\( i, val ) -> val == greatest)
                        |> List.head
                        |> Maybe.map Tuple.first
    in
    digit
--}

recognizeDigit : Matrix Float -> Maybe Int
recognizeDigit image =
    let
        totalWeight =
            image
                |> Array.map (Array.foldl (+) 0)
                |> Array.foldl (+) 0

        digitsSortedByWeight =
            Array.fromList [ 1, 7, 4, 3, 9, 5, 2, 6, 8, 0 ]

        index x =
            0.0004 * x * x - 0.0387 * x + 0.713

        digitIndex =
            totalWeight |> index |> round
    in
    Array.get digitIndex digitsSortedByWeight


view : Model -> Html Msg
view model =
    let
        vbWidth =
            pxSize * Matrix.colCount model.image

        vbHeight =
            controlHeight + pxSize * Matrix.rowCount model.image
    in
    div
        []
        [ Svg.svg
            [ Svg.Attributes.viewBox
                ("0 0 " ++ toString vbWidth ++ " " ++ toString vbHeight)
            , Svg.Attributes.preserveAspectRatio "xMidYMin meet"
            , Html.Attributes.style
                [ ( "display", "inline-block" )
                , ( "position", "absolute" )
                , ( "top", "0" )
                , ( "left", "0" )
                , ( "max-height", "100%" )
                ]
            ]
            [ Svg.g []
                (model.image
                    |> Array.map Array.toIndexedList
                    |> Array.toIndexedList
                    |> List.map (\( r, list ) -> List.map (\( c, v ) -> ( r, c, v )) list)
                    |> List.concat
                    |> List.map (\( row, col, val ) -> drawCell col row val)
                )
            , Svg.rect
                [ Svg.Attributes.width (toString vbWidth)
                , Svg.Attributes.height (toString controlHeight)
                , Svg.Attributes.x (toString 0)
                , Svg.Attributes.y (toString (vbHeight - controlHeight))
                , Svg.Attributes.fill "gray"
                , Svg.Events.onClick Clear
                ]
                []
            , Svg.text_
                [ Svg.Attributes.x (toString (vbWidth - 10))
                , Svg.Attributes.y (toString (vbHeight - 2))
                , Svg.Attributes.fill "white"
                ]
                [ Svg.text
                    (Maybe.map toString model.predicted
                        |> Maybe.withDefault "?"
                    )
                ]
            ]
        ]


drawCell : Int -> Int -> Float -> Svg Msg
drawCell col row value =
    let
        x =
            col * pxSize

        y =
            row * pxSize

        intensity =
            toString (clamp 0 255 (value * 255))

        fill =
            "rgb(" ++ intensity ++ ", " ++ intensity ++ ", " ++ intensity ++ ")"
    in
    Svg.rect
        [ Svg.Attributes.width (toString pxSize)
        , Svg.Attributes.height (toString pxSize)
        , Svg.Attributes.x (toString x)
        , Svg.Attributes.y (toString y)
        , Svg.Attributes.fill fill
        , onMouseMove (MouseOverCell col row)
        ]
        []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (\_ -> StartDrawing)
        , Mouse.ups (\_ -> StopDrawing)
        ]
