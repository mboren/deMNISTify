module Types exposing (..)
import Matrix exposing (Matrix)

type alias Model =
    { image : Matrix Float
    , drawing : Bool
    , previousDrawn : Maybe ( Int, Int )
    , predicted : Maybe Int
    , serverAddress : String
    }

type Msg
    = MouseOverCell Int Int
    | StartDrawing
    | StopDrawing
    | NewSocketMessage String
    | Clear
