!ram_gametime_room = $7FFB00
!ram_last_gametime_room = $7FFB02
!ram_realtime_room = $7FFB44
!ram_last_realtime_room = $7FFB46
!ram_last_room_lag = $7FFB48
!ram_transition_counter = $7FFB0E
!ram_last_door_lag_frames = $7FFB10

!ram_etanks = $7FFB12 ; ??
!ram_max_etanks = $7FFB24 ; ??
!ram_last_hp = $7FFB9A

!ram_display_mode = $7FFB60
!ram_frame_counter_mode = $7FFB8C
!ram_slowdown_mode = $7EFFFC
!ram_slowdown_frames = $7FFB52
!ram_dash_counter = $7FFB38
!ram_iframe_counter = $7FFB3A
!ram_vertical_speed = $7FFB3C
!ram_mb_hp = $7FFB3E
!ram_enemy_hp = $7FFB40
!ram_shine_counter_1 = $7FFB30 ; goes 1-A
!ram_shine_counter_2 = $7FFB14 ; armed shine duration
!ram_shine_counter_3 = $7FFB1A ; armed shine duration 2
!ram_magic_pants_1 = $7FFB64
!ram_magic_pants_2 = $7FFB66
!ram_magic_pants_3 = $7FFB70
!ram_magic_pants_4 = $7FFB72
!ram_magic_pants_5 = $7FFB74
!ram_charge_counter = $7FFB1C
!ram_xfac_counter = $7FFB1E
!ram_lag_counter = $7FFB96
!ram_last_lag_counter = $7FFB98

!ram_rerandomize = $7FFB80
!ram_phantoon_rng_1 = $7FFB82
!ram_phantoon_rng_2 = $7FFB84
!ram_phantoon_rng_3 = $7FFB86
!ram_phantoon_rng_4 = $7FFB88
!ram_botwoon_rng = $7FFB8A

!ram_tmp_1 = $7FFB4C
!ram_tmp_2 = $7FFB4E
!ram_tmp_3 = $7FFB08
!ram_tmp_4 = $7FFB0A
!ram_transition_flag = $7FFB16
!ram_transition_flag_2 = $7FFB2C
!ram_pct_1 = $7FFB20
!ram_pct_2 = $7FFB26
!ram_ih_controller = $7FFB42
!ram_slowdown_controller_1 = $7FFB54
!ram_slowdown_controller_2 = $7FFB56

!ram_seg_rt_frames = $7FFBA0
!ram_seg_rt_seconds = $7FFBA2
!ram_seg_rt_minutes = $7FFBA4

!ram_hex2dec_first_digit = $14
!ram_hex2dec_second_digit = $16
!ram_hex2dec_third_digit = $18
!ram_hex2dec_rest = $1A

!ram_artificial_lag = $7FFBA6

; -------------
; Menu
; -------------

!ram_cm_menu_stack = $7FFFD0 ; 0x10
!ram_cm_cursor_stack = $7FFFE0 ; 0x10
!ram_cm_stack_index = $5D5
!ram_cm_cursor_max = $7FFFF2
!ram_cm_input_timer = $7FFFF4
!ram_cm_controller = $7FFFF6

!ram_cm_etanks = $7FFB90
!ram_cm_reserve = $7FFB92
!ram_cm_leave = $7FFB94

!MENU_CONTROLLER = $8B
!MENU_INPUT = #$3000 ; select + start

!ACTION_TOGGLE      = #$0000
!ACTION_TOGGLE_BIT  = #$0002
!ACTION_JSR         = #$0004
!ACTION_NUMFIELD    = #$0006
!ACTION_CHOICE      = #$0008

; ------------
; Presets
; ------------

!ram_load_preset = $7FFC00
!ram_cgram_cache = $7FFC02 ; 0x14 bytes
