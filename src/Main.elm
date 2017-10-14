module Main exposing (..)

import Html exposing (Html, text, div, table, tr, td, button, span, p)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


---- MODEL ----


type GameStatus
    = NotStarted
    | InProgress
    | Drawn
    | WonBy Player


type Player
    = X
    | O


type alias Cell =
    { owner : Maybe Player
    , location : CellLocation
    }


type alias CellLocation =
    { row : Int
    , column : Int
    }


type alias Board =
    List Cell


type alias Model =
    { board : Board
    , currentTurn : Player
    , gameStatus : GameStatus
    }


init : ( Model, Cmd Msg )
init =
    { board = initBoard
    , currentTurn = O
    , gameStatus = NotStarted
    }
        ! []


initBoard : Board
initBoard =
    let
        cellAt row col =
            CellLocation row col |> Cell Nothing
    in
        [ cellAt 0 0
        , cellAt 0 1
        , cellAt 0 2
        , cellAt 1 0
        , cellAt 1 1
        , cellAt 1 2
        , cellAt 2 0
        , cellAt 2 1
        , cellAt 2 2
        ]



---- UPDATE ----


type Msg
    = NewGame


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewGame ->
            let
                ( newModel, cmd ) =
                    init
            in
                { newModel | gameStatus = InProgress } ! [ cmd ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ viewBoardHeader model
        , viewBoard model.board
        , viewBoardFooter model
        ]


viewBoard : Board -> Html Msg
viewBoard board =
    board |> board2D |> List.map viewRow |> table []


viewBoardHeader : Model -> Html Msg
viewBoardHeader model =
    let
        view_ =
            case model.gameStatus of
                InProgress ->
                    viewCurrentTurn model.currentTurn

                Drawn ->
                    Html.text "Drawn"

                WonBy player ->
                    Html.text ("Won by " ++ toString player)

                NotStarted ->
                    Html.text ""
    in
        p [ class "boardHeader" ]
            [ view_ ]


viewBoardFooter : Model -> Html Msg
viewBoardFooter model =
    p [ class "boardFooter" ] [ startButton model.gameStatus ]


board2D : Board -> List (List Cell)
board2D board =
    let
        totalCells =
            List.length board

        rows =
            totalCells |> toFloat |> sqrt |> round

        rowIndices =
            List.range 0 (rows - 1)

        cellsInRow row =
            List.filter (\cell -> row == cell.location.row) board
    in
        List.map cellsInRow rowIndices


viewRow : List Cell -> Html Msg
viewRow row =
    List.map viewCell row |> tr []


viewCell : Cell -> Html Msg
viewCell cell =
    td [ class ("player" ++ toString cell.owner) ]
        [ text (cellOwnerString cell.owner) ]


cellOwnerString : Maybe Player -> String
cellOwnerString owner =
    case owner of
        Just player ->
            playerName player

        Nothing ->
            ""


viewCurrentTurn : Player -> Html Msg
viewCurrentTurn player =
    span [ class "topLine" ]
        [ span [ class ("player player" ++ toString player) ]
            [ text (playerName player) ]
        , text "'s turn!"
        ]


playerName : Player -> String
playerName player =
    case player of
        X ->
            "✕"

        O ->
            "●"


startButton : GameStatus -> Html Msg
startButton gameStatus =
    case gameStatus of
        InProgress ->
            Html.text ""

        _ ->
            button [ onClick NewGame ] [ text "Start New Game" ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
