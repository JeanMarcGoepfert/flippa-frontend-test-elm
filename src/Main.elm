module Main exposing (..)

import Html exposing (Html, text, div, span)
import Http
import Json.Decode as Decode


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Item =
    { id : String
    , title : String
    , count : Int
    }


type alias Model =
    { items : List Item
    , loading : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { items = []
      , loading = True
      }
    , getItems
    )



-- UPDATE


type Msg
    = Init
    | GetItems (Result Http.Error (List Item))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )

        GetItems (Ok items) ->
            ( { model | loading = False, items = items }, Cmd.none )

        GetItems (Err error) ->
            ( { model | loading = False }, Cmd.none )



-- HTTTP


getItems : Cmd Msg
getItems =
    Http.send GetItems (Http.get "/api/v1/counters" decodeItems)


decodeItems : Decode.Decoder (List Item)
decodeItems =
    Decode.list itemDecoder


itemDecoder : Decode.Decoder Item
itemDecoder =
    Decode.map3 Item
        (Decode.field "id" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "count" Decode.int)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    if model.loading then
        div [] [ text "Loading" ]
    else
        div []
            (List.map (\i -> itemView i) model.items)


itemView : Item -> Html Msg
itemView item =
    div []
        [ span [] [ text ("id: " ++ item.id ++ ", ") ]
        , span [] [ text ("title: " ++ item.title ++ ", ") ]
        , span [] [ text ("count:  " ++ toString item.count) ]
        ]
