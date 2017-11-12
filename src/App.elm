module Main exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (Html, div, text)
import Matrix exposing (Matrix)


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
    div [] []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
