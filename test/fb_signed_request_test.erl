-module(fb_signed_request_test).

-compile(export_all).

% Include etest's assertion macros.
-include_lib("etest/include/etest.hrl").

-define(FB_SECRET, "897z956a2z7zzzzz5783z458zz3z7556").
-define(VALID_REQ, "Z9Xn16Pdo5ac9YWDh5HD70aujhsZ9eCoyPMcpd2aaiM.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImFnZSI6eyJtaW4iOjIxfSwiY291bnRyeSI6ImRlIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_FORMAT, "Z9Xn16Pdo5ac9YWDh5HD70aujhsZ9eCoyPMcpd2aaiM2eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImFnZSI6eyJtaW4iOjIxfSwiY291bnRyeSI6ImRlIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_PAYLOAD, "Z9Xn16Pdo5ac9YWDh5HD70aujhsZ9eCoyPMcpd2aaiM.*yJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImFnZSI6eyJtaW4iOjIxfSwiY291bnRyeSI6ImRlIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_SIGNATURE, "umfudisP7mKhsi9nZboBg15yMZKhfQAARL9UoZtSE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_ALGORITHM, "r9V9QJKT6_Zu0nvgzdKBF3mPUjttpuc6sXVBSsQbINg.eyJhbGdvcml0aG0iOiJ1bmtub3duIiwiZXhwaXJlcyI6MTMwODk4ODgwMCwiaXNzdWVkX2F0IjoxMzA4OTg1MDE4LCJvYXV0aF90b2tlbiI6IjExMTExMTExMTExMTExMXwyLkFRQkF0dFJsTFZud3FOUFouMzYwMC4xMTExMTExMTExLjEtMTExMTExMTExMTExMTExfFQ0OXczQnFvWlVlZ3lwcnU1MUdyYTcwaEVEOCIsInVzZXIiOnsiYWdlIjp7Im1pbiI6MjF9LCJjb3VudHJ5IjoiZGUiLCJsb2NhbGUiOiJlbl9VUyJ9LCJ1c2VyX2lkIjoiMTExMTExMTExMTExMTExIn0").
-define(URL_PAYLOAD_FROM_FB, <<"eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNyZWRpdHMiOnsib3JkZXJfZGV0YWlscyI6IntcIm9yZGVyX2lkXCI6NDY1MzA0MTg2ODczNDIxLFwiYnV5ZXJcIjoxMDAwMDUxMTQ4NjA5MDAsXCJhcHBcIjoxNTYzNjE4Mzc3NjYyNzIsXCJyZWNlaXZlclwiOjEwMDAwNTExNDg2MDkwMCxcImN1cnJlbmN5XCI6XCJGQlpcIixcImFtb3VudFwiOjQ5OSxcInRpbWVfcGxhY2VkXCI6MTM2ODYxMzA3MCxcInByb3BlcnRpZXNcIjoxLFwidXBkYXRlX3RpbWVcIjoxMzY4NjEzMDcyLFwiZGF0YVwiOlwiXCIsXCJyZWZfb3JkZXJfaWRcIjowLFwiaXRlbXNcIjpbe1wiaXRlbV9pZFwiOlwiMFwiLFwidGl0bGVcIjpcIjE0OTcwIGZiLm9wZW5ncmFwaC5jb2luc190aXRsZVwiLFwiZGVzY3JpcHRpb25cIjpcImZiLm9wZW5ncmFwaC5jb2luc1wiLFwiaW1hZ2VfdXJsXCI6XCJodHRwczpcXFwvXFxcL2ZiZXh0ZXJuYWwtYS5ha2FtYWloZC5uZXRcXFwvc2FmZV9pbWFnZS5waHA_ZD1BUUNJMlJPUFcwVVBKZlJBJnVybD1odHRwXFx1MDAyNTNBXFx1MDAyNTJGXFx1MDAyNTJGYXNzZXRzMi5nOC53b29nYS5jb21cXHUwMDI1MkZhc3NldHNcXHUwMDI1MkZ1aVxcdTAwMjUyRnBheW1lbnRcXHUwMDI1MkZjb2luX3BhY2thZ2VfYmlnXzAxLjM0NTczZGM3MjI3ZDNhMWM4YTU3ODVmOThlMzY2M2UxLnBuZ1wiLFwicHJvZHVjdF91cmxcIjpcIlwiLFwicHJpY2VcIjo0OTksXCJkYXRhXCI6XCJ7XFxcIm1vZGlmaWVkXFxcIjp7XFxcInByb2R1Y3RcXFwiOlxcXCJodHRwczpcXFxcXFxcL1xcXFxcXFwvYXBwcy5mYWNlYm9vay5jb21cXFxcXFxcL2dhbWVlaWdodGludGVncmF0aW9uXFxcXFxcXC9vZ1xcXFxcXFwvY3VycmVuY3k_cmVmPW9wZW5ncmFwaCZvYmplY3RfaWQ9Y29pbnNcXFwiLFxcXCJwcm9kdWN0X3RpdGxlXFxcIjpcXFwiZmIub3BlbmdyYXBoLmNvaW5zX3RpdGxlXFxcIixcXFwicHJvZHVjdF9hbW91bnRcXFwiOjE0OTcwLFxcXCJjcmVkaXRzX2Ftb3VudFxcXCI6NDk5fX1cIn1dLFwic3RhdHVzXCI6XCJwbGFjZWRcIn0iLCJzb3VyY2UiOm51bGwsInN0YXR1cyI6InBsYWNlZCIsIm9yZGVyX2lkIjo0NjUzMDQxODY4NzM0MjEsInRlc3RfbW9kZSI6MX0sImV4cGlyZXMiOjEzNjg2MTkyMDAsImlzc3VlZF9hdCI6MTM2ODYxMzA3Mywib2F1dGhfdG9rZW4iOiJDQUFDT05kUEw1b0FCQUhpMDkzU2Q4V1pBZ1B2Rk5iMEl6cTM1Rkdnd1k2Y0FhVnVnSU1xb243OE81ZjZmdU94RXpmVFZDVUNNd1VUdk9Ja1BlbTBFdnJubDlaQmhZVTExU0ZTVnJUaVVsa0N2bUtoWkNzQnlXQVlnc2luSk9ialJBb1ZBR2drWkJZeTBiQnVJOXZ0cUdMNWQ4aDROUzVrWkQiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjEwMDAwNTExNDg2MDkwMCJ9">>).
-define(EXPECTED_VALID_DATA, <<"{\"algorithm\":\"HMAC-SHA256\",\"expires\":1308988800,\"issued_at\":1308985018,\"oauth_token\":\"111111111111111|2.AQBAttRlLVnwqNPZ.3600.1111111111.1-111111111111111|T49w3BqoZUegypru51Gra70hED8\",\"user\":{\"age\":{\"min\":21},\"country\":\"de\",\"locale\":\"en_US\"},\"user_id\":\"111111111111111\"}">>).
-define(EXPECTED_VALID_URL_PAYLOAD, <<"{\"algorithm\":\"HMAC-SHA256\",\"credits\":{\"order_details\":\"{\\\"order_id\\\":465304186873421,\\\"buyer\\\":100005114860900,\\\"app\\\":156361837766272,\\\"receiver\\\":100005114860900,\\\"currency\\\":\\\"FBZ\\\",\\\"amount\\\":499,\\\"time_placed\\\":1368613070,\\\"properties\\\":1,\\\"update_time\\\":1368613072,\\\"data\\\":\\\"\\\",\\\"ref_order_id\\\":0,\\\"items\\\":[{\\\"item_id\\\":\\\"0\\\",\\\"title\\\":\\\"14970 fb.opengraph.coins_title\\\",\\\"description\\\":\\\"fb.opengraph.coins\\\",\\\"image_url\\\":\\\"https:\\\\\\/\\\\\\/fbexternal-a.akamaihd.net\\\\\\/safe_image.php?d=AQCI2ROPW0UPJfRA&url=http\\\\u00253A\\\\u00252F\\\\u00252Fassets2.g8.wooga.com\\\\u00252Fassets\\\\u00252Fui\\\\u00252Fpayment\\\\u00252Fcoin_package_big_01.34573dc7227d3a1c8a5785f98e3663e1.png\\\",\\\"product_url\\\":\\\"\\\",\\\"price\\\":499,\\\"data\\\":\\\"{\\\\\\\"modified\\\\\\\":{\\\\\\\"product\\\\\\\":\\\\\\\"https:\\\\\\\\\\\\\\/\\\\\\\\\\\\\\/apps.facebook.com\\\\\\\\\\\\\\/gameeightintegration\\\\\\\\\\\\\\/og\\\\\\\\\\\\\\/currency?ref=opengraph&object_id=coins\\\\\\\",\\\\\\\"product_title\\\\\\\":\\\\\\\"fb.opengraph.coins_title\\\\\\\",\\\\\\\"product_amount\\\\\\\":14970,\\\\\\\"credits_amount\\\\\\\":499}}\\\"}],\\\"status\\\":\\\"placed\\\"}\",\"source\":null,\"status\":\"placed\",\"order_id\":465304186873421,\"test_mode\":1},\"expires\":1368619200,\"issued_at\":1368613073,\"oauth_token\":\"CAACONdPL5oABAHi093Sd8WZAgPvFNb0Izq35FGgwY6cAaVugIMqon78O5f6fuOxEzfTVCUCMwUTvOIkPem0Evrnl9ZBhYU11SFSVrTiUlkCvmKhZCsByWAYgsinJObjRAoVAGgkZBYy0bBuI9vtqGL5d8h4NS5kZD\",\"user\":{\"country\":\"de\",\"locale\":\"en_US\",\"age\":{\"min\":21}},\"user_id\":\"100005114860900\"}">>).

test_parsing_a_valid_request() ->
    Result = fb_signed_request:parse(?VALID_REQ, ?FB_SECRET),
    ?assert_equal({ok, ?EXPECTED_VALID_DATA}, Result).


test_parsing_a_request_with_invalid_format() ->
    Result = fb_signed_request:parse(?INVALID_REQ_FORMAT, ?FB_SECRET),
    ?assert_equal({error, invalid_format}, Result).


test_parsing_a_request_with_invalid_payload() ->
    Result = fb_signed_request:parse(?INVALID_REQ_PAYLOAD, ?FB_SECRET),
    ?assert_equal({error, invalid_payload}, Result).


test_parsing_a_request_with_invalid_signature() ->
    Result = fb_signed_request:parse(?INVALID_REQ_SIGNATURE, ?FB_SECRET),
    ?assert_equal({error, invalid_signature}, Result).


test_parsing_a_invalid_request_algorithm() ->
    Result = fb_signed_request:parse(?INVALID_REQ_ALGORITHM, ?FB_SECRET),
    ?assert_equal({error, unsupported_algorithm}, Result).


test_generating_a_invalid_request() ->
    SignedRequest = fb_signed_request:generate(?INVALID_REQ_ALGORITHM, ?FB_SECRET),
    Result = fb_signed_request:parse(SignedRequest, "c2b7476a4b7078bcd816da55bb8fe22d"),
    ?assert_equal({error, unsupported_algorithm}, Result).


test_generating_and_parsing_and_validating_a_request() ->
    SignedRequest       = fb_signed_request:generate(?EXPECTED_VALID_DATA, ?FB_SECRET),
    ?assert_equal(?VALID_REQ, SignedRequest),
    {ok, ParsedRequest} = fb_signed_request:parse(SignedRequest, ?FB_SECRET),
    ?assert_equal(ParsedRequest, ?EXPECTED_VALID_DATA).


test_generate_signed_request_as_binary() ->
    SignedRequest = fb_signed_request:generate(
        ?EXPECTED_VALID_DATA, ?FB_SECRET, [{return, binary}]
    ),

    ?assert_equal(erlang:list_to_binary(?VALID_REQ), SignedRequest).

test_parsing_url_data() ->
    ?assert_equal(fb_signed_request:decode_body(?URL_PAYLOAD_FROM_FB),
                  ?EXPECTED_VALID_URL_PAYLOAD).
