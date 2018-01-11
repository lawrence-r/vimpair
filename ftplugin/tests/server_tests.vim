python from mock import Mock
execute("source " . expand("<sfile>:p:h") . "/test_tools.vim")
execute("source " . expand("<sfile>:p:h") . "/../vimpair.vim")


function! _VPServerTest_set_up()
  execute("vnew")
  call VimpairServerStart()
  python fake_connection = Mock()
  python connections.append(fake_connection)
endfunction

function! _VPServerTest_tear_down()
  call VimpairServerStop()
  execute("q!")
endfunction

function! _VPServerTest_assert_has_sent_message(expected)
  let g:_VPServerTest_expected = a:expected
  python fake_connection.send_message.assert_any_call(
    \ vim.vars['_VPServerTest_expected'])
endfunction


function! VPServerTest_sends_buffer_contents_on_connection()
  execute("normal iThis is just some text")

  call _VPServerTest_assert_has_sent_message(
    \ "VIMPAIR_FULL_UPDATE|22|This is just some text")
endfunction

function! VPServerTest_sends_cursor_position_on_connection()
  execute("normal iThis is line one")
  execute("normal oThis is line two")

  execute("normal gg0ww")
  " The CursorMoved autocommand is not reported in this scope,
  " so we need to manually trigger it
  execute("doautocmd CursorMoved")

  call _VPServerTest_assert_has_sent_message("VIMPAIR_CURSOR_POSITION|0|8")
endfunction


call VPTestTools_run_tests("VPServerTest")
