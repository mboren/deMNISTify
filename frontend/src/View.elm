module View exposing (root)

import Array exposing (Array)
import Html exposing (Html, div, text)
import Html.Attributes
import Matrix exposing (Matrix, loc)
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events exposing (onMouseMove)
import Types exposing (Model, Msg(..))


pxSize =
    10


root : Model -> Html Msg
root model =
    let
        vbWidth =
            pxSize * Matrix.colCount model.image

        vbHeight =
            1.2 * pxSize * toFloat (Matrix.rowCount model.image)

        controlHeight =
            0.2 * pxSize * toFloat (Matrix.rowCount model.image)
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
                [ Svg.Attributes.width (toString (toFloat vbWidth / 2))
                , Svg.Attributes.height (toString controlHeight)
                , Svg.Attributes.x (toString 0)
                , Svg.Attributes.y (toString (vbHeight - controlHeight))
                , Svg.Attributes.fill "gray"
                ]
                []
            , Svg.rect
                [ Svg.Attributes.width (toString (toFloat vbWidth / 2))
                , Svg.Attributes.height (toString controlHeight)
                , Svg.Attributes.x (toString (toFloat vbWidth / 2))
                , Svg.Attributes.y (toString (vbHeight - controlHeight))
                , Svg.Attributes.fill "darkgray"
                , Svg.Events.onClick Clear
                ]
                []
            , Svg.text_
                [ Svg.Attributes.x (toString (toFloat vbWidth / 5))
                , Svg.Attributes.y (toString (vbHeight - 4))
                , Svg.Attributes.fill "white"
                , Svg.Attributes.fontSize (toString (controlHeight + 4))
                , Svg.Attributes.fontFamily "Verdana"
                ]
                [ Svg.text
                    (Maybe.map toString model.predicted
                        |> Maybe.withDefault "?"
                    )
                ]
            , Svg.text_
                [ Svg.Attributes.x (toString (toFloat vbWidth / 2))
                , Svg.Attributes.y (toString (vbHeight - 4))
                , Svg.Attributes.fontSize (toString (controlHeight + 4))
                , Svg.Attributes.fill "white"
                , Svg.Events.onClick Clear
                ]
                [ Svg.text "Clear"
                ]
            ]
        ]


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
        -- I put each row in their own SVG group purely to make it easier
        -- to find things when inspecting the DOM tree with Chrome DevTools
        |> Svg.g []


drawCell : Bool -> Int -> Int -> Float -> Svg Msg
drawCell setMouseEvent row col value =
    let
        x =
            col * pxSize

        y =
            row * pxSize

        intensity =
            toString (clamp 0 255 (floor (value * 255)))

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
                    [ onMouseMove (MouseOverCell row col) ]
                else
                    []
               )
        )
        []
