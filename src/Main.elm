module Main exposing (..)

import Html exposing (Html, text, div, span, input, form, button)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onSubmit, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


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


type alias ItemForm =
    { title : String }


type alias Model =
    { items : List Item
    , loading : Bool
    , itemForm : ItemForm
    }


init : ( Model, Cmd Msg )
init =
    ( { items = []
      , loading = True
      , itemForm = { title = "" }
      }
    , getItems
    )



-- UPDATE


type Msg
    = Init
    | GetItems (Result Http.Error (List Item))
    | SubmitNewItem
    | ChangeNewItem String
    | CreateItem (Result Http.Error (List Item))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )

        GetItems (Ok items) ->
            ( { model | loading = False, items = items }, Cmd.none )

        GetItems (Err error) ->
            ( { model | loading = False }, Cmd.none )

        CreateItem (Ok items) ->
            ( { model | loading = False, items = items }, Cmd.none )

        CreateItem (Err error) ->
            ( { model | loading = False }, Cmd.none )

        SubmitNewItem ->
            let
                itemForm =
                    { title = "" }
            in
                ( { model | itemForm = itemForm, loading = True }
                , createItem model.itemForm.title
                )

        ChangeNewItem newTitle ->
            let
                itemForm =
                    { title = newTitle }
            in
                ( { model | itemForm = itemForm }, Cmd.none )



-- HTTTP


getItems : Cmd Msg
getItems =
    Http.send GetItems (Http.get "/api/v1/counters" decodeItems)


createItem : String -> Cmd Msg
createItem itemName =
    let
        body =
            itemName
                |> itemEncoder
                |> Http.jsonBody
    in
        Http.send CreateItem (Http.post "/api/v1/counter" body decodeItems)


itemEncoder : String -> Encode.Value
itemEncoder itemName =
    Encode.object
        [ ( "title", Encode.string itemName ) ]


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
            [ newItem model
            , div [] (List.map (\i -> itemView i) model.items)
            ]


newItem : Model -> Html Msg
newItem model =
    form [ onSubmit SubmitNewItem ]
        [ input
            [ placeholder "Enter an item"
            , onInput ChangeNewItem
            , value model.itemForm.title
            ]
            []
        , button [ type_ "submit" ] [ text "Add" ]
        ]


itemView : Item -> Html Msg
itemView item =
    div []
        [ span [] [ text ("id: " ++ item.id ++ ", ") ]
        , span [] [ text ("title: " ++ item.title ++ ", ") ]
        , span [] [ text ("count:  " ++ toString item.count) ]
        ]
