port module Main exposing (..)

import Array exposing (Array)
import Html exposing (Html, div, text)
import Html.Attributes
import Matrix exposing (Matrix, loc)
import MatrixMath
import Mouse
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events exposing (onMouseMove)


pxSize =
    10


controlHeight =
    15


{-| Send a flattened image to JS classifier
-}
port sendImage : List Float -> Cmd msg


{-| Get digit predicted by JS classifier
-}
port getPrediction : (Int -> msg) -> Sub msg


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
    | NewPrediction Int
    | Clear


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseOverCell col row ->
            if model.drawing && Just ( col, row ) /= model.previousDrawn then
                let
                    delta =
                        List.range -1 1

                    neighbors =
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
                                colorNeighbors (Matrix.update location (\v -> min 1 (v + 0.4)) image) tail

                    newImage =
                        colorNeighbors model.image neighbors
                            |> Matrix.set (loc row col) 1.0
                in
                ( { model
                    | image = newImage
                    , previousDrawn = Just ( col, row )
                  }
                , sendImage (Matrix.flatten (MatrixMath.center newImage))
                )
            else
                ( model, Cmd.none )

        NewPrediction i ->
            ( { model | predicted = Just i }, Cmd.none )

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
            [ drawImage model.drawing model.image
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


drawCell : Bool -> Int -> Int -> Float -> Svg Msg
drawCell setMouseEvent row col value =
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
        ([ Svg.Attributes.width (toString pxSize)
         , Svg.Attributes.height (toString pxSize)
         , Svg.Attributes.x (toString x)
         , Svg.Attributes.y (toString y)
         , Svg.Attributes.fill fill
         ]
            ++ (if setMouseEvent then
                    [ onMouseMove (MouseOverCell col row) ]
                else
                    []
               )
        )
        []

drawImage : Bool -> Matrix Float -> Svg Msg
drawImage setMouseEvent image =
    image
        |> Array.indexedMap (drawImageRow setMouseEvent)
        |> Array.toList
        |> Svg.g []


drawImageRow : Bool -> Int -> Array Float -> Svg Msg
drawImageRow setMouseEvent rowIndex row =
    row
        |> Array.indexedMap (drawCell setMouseEvent rowIndex)
        |> Array.toList
        |> Svg.g []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (\_ -> StartDrawing)
        , Mouse.ups (\_ -> StopDrawing)
        , getPrediction NewPrediction
        ]
