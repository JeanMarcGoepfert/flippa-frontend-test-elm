module Main exposing (..)

import Html exposing (Html, text, div, span, input, form, button)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onSubmit, onInput, onClick)
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
    | GetItemsResponse (Result Http.Error (List Item))
    | SubmitNewItem
    | ChangeNewItem String
    | CreateItem (Result Http.Error (List Item))
    | IncrementItem String
    | IncrementItemResponse (Result Http.Error (List Item))
    | DecrementItem String
    | DecrementItemResponse (Result Http.Error (List Item))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )

        GetItemsResponse (Ok items) ->
            ( { model | loading = False, items = items }, Cmd.none )

        GetItemsResponse (Err error) ->
            ( { model | loading = False }, Cmd.none )

        CreateItem (Ok items) ->
            ( { model | loading = False, items = items }, Cmd.none )

        IncrementItemResponse (Err error) ->
            ( { model | loading = False }, Cmd.none )

        IncrementItemResponse (Ok items) ->
            ( { model | loading = False, items = items }, Cmd.none )

        DecrementItemResponse (Err error) ->
            ( { model | loading = False }, Cmd.none )

        DecrementItemResponse (Ok items) ->
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

        IncrementItem itemId ->
            ( { model | loading = True }, incrementItem itemId )

        DecrementItem itemId ->
            ( { model | loading = True }, decrementItem itemId )



-- HTTTP


getItems : Cmd Msg
getItems =
    Http.send GetItemsResponse (Http.get "/api/v1/counters" decodeItems)


createItem : String -> Cmd Msg
createItem itemName =
    let
        body =
            itemName
                |> (\name -> Encode.object [ ( "title", Encode.string name ) ])
                |> Http.jsonBody
    in
        Http.send CreateItem (Http.post "/api/v1/counter" body decodeItems)


incrementItem : String -> Cmd Msg
incrementItem itemId =
    let
        body =
            itemId
                |> (\id -> Encode.object [ ( "id", Encode.string id ) ])
                |> Http.jsonBody
    in
        Http.send IncrementItemResponse
            (Http.post "/api/v1/counter/inc" body decodeItems)


decrementItem : String -> Cmd Msg
decrementItem itemId =
    let
        body =
            itemId
                |> (\id -> Encode.object [ ( "id", Encode.string id ) ])
                |> Http.jsonBody
    in
        Http.send DecrementItemResponse
            (Http.post "/api/v1/counter/dec" body decodeItems)


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
        , button [ onClick (DecrementItem item.id) ] [ text "-" ]
        , button [ onClick (IncrementItem item.id) ] [ text "+" ]
        ]
