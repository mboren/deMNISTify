module Main exposing (Model, Msg, init, subscriptions, update, view)

import Array exposing (Array)
import Html exposing (Html, div, text)
import Html.Attributes
import Matrix exposing (Matrix)
import Mouse
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events exposing (onMouseMove)


pxSize =
    10

controlHeight =
    10



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
    }


init : ( Model, Cmd Msg )
init =
    let
        image =
            Matrix.fromList
                [ [ 0, 0, 0, 0 ]
                , [ 0, 0, 0, 0 ]
                , [ 0, 0, 0, 0 ]
                , [ 0, 0, 0, 0 ]
                ]
                |> Maybe.withDefault Matrix.empty
    in
    ( Model image False, Cmd.none )


type Msg
    = MouseOverCell Int Int
    | StartDrawing
    | StopDrawing
    | Clear


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseOverCell col row ->
            if model.drawing then
                let
                    newImage =
                        Matrix.set col row 1.0 model.image
                in
                ( { model | image = newImage }, Cmd.none )
            else
                ( model, Cmd.none )

        StartDrawing ->
            ( { model | drawing = True }, Cmd.none )

        StopDrawing ->
            ( { model | drawing = False }, Cmd.none )

        Clear ->
            let
                ( cols, rows ) =
                    model.image.size

                newImage =
                    Matrix.repeat cols rows 0
            in
            ( { model | image = newImage }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        vbWidth =
            pxSize * Matrix.width model.image

        vbHeight =
            controlHeight + pxSize * Matrix.height model.image
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
                (Matrix.toIndexedArray model.image
                    |> Array.toList
                    |> List.map (\( ( col, row ), val ) -> drawCell col row val)
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
            ]
        ]


drawCell : Int -> Int -> Float -> Svg Msg
drawCell col row value =
    let
        x =
            col * pxSize

        y =
            row * pxSize

        fill =
            if value == 0.0 then
                "white"
            else
                "black"
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
