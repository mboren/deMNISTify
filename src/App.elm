module Main exposing (Model, Msg, init, subscriptions, update, view)

import Array exposing (Array)
import Html exposing (Html, div, text)
import Html.Attributes
import Matrix exposing (Matrix)
import Svg exposing (Svg)
import Svg.Attributes


pxSize =
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
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            Matrix.fromList
                [ [ 1, 0, 1, 0 ]
                , [ 1, 0, 1, 0 ]
                , [ 1, 0, 1, 0 ]
                , [ 1, 0, 1, 0 ]
                ]
                |> Maybe.withDefault Matrix.empty
                |> Model
    in
    ( model, Cmd.none )


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        vbWidth =
            pxSize * Matrix.width model.image

        vbHeight =
            pxSize * Matrix.height model.image
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
            (Matrix.toIndexedArray model.image
                |> Array.toList
                |> List.map (\( ( col, row ), val ) -> drawCell col row val)
            )
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
        ]
        []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
