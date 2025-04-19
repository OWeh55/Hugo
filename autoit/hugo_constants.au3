; constants for hugo
Global Const $PName = "hugo"

Global Const $Version = "3.5.6"

Global Const $MaxGleise = 150
Global Const $SpeedLogSize = 120

; indices in track data array
Global Const $TrackDataLen = 16

;; basic data from input
;; enough to call gleis.dll
Global Const $ix = 0
Global Const $iy = 1
Global Const $idir = 2
Global Const $iangle = 3
Global Const $ilen = 4
Global Const $ih1 = 5
Global Const $igrad = 6
Global Const $ibend = 7

;; extended data
;; delivered by gleis.dll
;; used by graphic, ...

Global Const $ieh2 = 8
Global Const $ixe = 9
Global Const $iye = 10
Global Const $ixm = 11
Global Const $iym = 12
Global Const $irad = 13
Global Const $ifi1 = 14
Global Const $ifi2 = 15

; control id for property window of track

Global Const $id_angle = 1352	; Winkel(a) --> $gleis[$iangle] bleibt
Global Const $id_len = 1356 	; Länge(l) --> $gleis[$ilen] bleibt
Global Const $id_x = 1354		; Pos.X --> $gleis[$ix] bleibt
Global Const $id_y = 1359		; Pos.Y --> $gleis[$iy] bleibt
Global Const $id_h1 = 1351		; Abs.H. --> $gleis[$ih1] 1670
Global Const $id_h16 = 1670     ; Abs.H. --> $gleis[$ih1] EEP16
Global Const $id_dir = 1360		; Winkel(z) --> $gleis[$idir] bleibt
Global Const $id_steigung = 1313	; Steigung(m) --> $gleis[$igrad] 1310
Global Const $id_steigung16 = 1310	; Steigung(m) --> $gleis[$igrad] EEP16
Global Const $id_bend = 1315	; Biegung(z) --> $gleis[$ibend] bleibt

Global Const $id_parmode = 1289 ; Auswahl Charakteristik --> wird auf Winkel + Länge + Biegung + Steigung(°) gestellt --> 1. Einrag
Global Const $id_glmode = 1290 ; 1290 Geistyp --> 3. Eintrag EEP16

; Weitere
; 1147 Rel.H.
; 1365 Skalierung
; 1311 Gleisüberhöhung Anfang
; 1312 Gleisüberhöhung Ende

; indexes in object data
Global Const $iiname = 0
Global Const $iix = 1
Global Const $iiy = 2
Global Const $iiz = 3
Global Const $iizr = 4
Global Const $iifx = 5
Global Const $iify = 6
Global Const $iifz = 7
Global Const $iiscx = 8
Global Const $iiscy = 9
Global Const $iiscz = 10
Global Const $iilight = 11
Global Const $iishadow = 12
Global Const $iismoke = 13
Global Const $iifire = 14
Global Const $iiswim = 15

Global Const $immosize = 16

; control id for immo_property window
Global Const $iid_x = 1144
Global Const $iid_y = 1145
Global Const $iid_z = 1142

Global Const $iid_zr = 1143

Global Const $iid_fx = 1309
Global Const $iid_fy = 1378
Global Const $iid_fz = 1379

Global Const $iid_light = 1103

Global Const $iid_scx = 1395
Global Const $iid_scy = 1396
Global Const $iid_scz = 1397

Global Const $iid_shadow = 1538
Global Const $iid_smoke = 1535
Global Const $iid_fire = 1537

Global Const $iid_swim = 1146

Global Const $color[6] = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x00ffff, 0xffffff]
Global Const $BitMask[8] = [1, 2, 4, 8, 16, 32, 64, 128]

Global Const $degToRad = 3.14159265 / 180.0

;; button list is 2-dimensional array with editor and function as index
;; indices of editors in editor/button array
Global Const $eid_track = 0 ; index of track editor
Global Const $eid_tram = 1 ; index of tram editor
Global Const $eid_road = 2 ; index of road editor
Global Const $eid_water = 3 ; index of water editor

;; indices of buttons in editor/button array
Global Const $bid_track = 0 ; index of track button
Global Const $bid_switch = 1 ; index of Switch button
Global Const $bid_switch3 = 2 ; index of switch3 button
Global Const $bid_end = 3 ; index of End button
Global Const $bid_del = 4 ; index of del button
Global Const $bid_level = 5 ; index of level button
Global Const $bid_obj = 6 ; index of Obj button
Global Const $bid_copy = 7 ; index of copy button
Global Const $bid_left = 8 ; index of left button
Global Const $bid_forward = 9 ; index of forward button
Global Const $bid_right = 10 ; index of right button
Global Const $bid_inv = 11 ; index of inv button

;; status of graphics display
Global Const $TrackDisplay = 1
Global Const $ImmoDisplay = 2
Global Const $SpeedDisplay = 3

;; ini file with user settings
Global Const $inifile = @ScriptDir & "\" & $PName & ".ini"

;; default values for shift of immo etc.
Global Const $valfile = @ScriptDir & "\" & $PName & ".val"

;; hugo language file
Global Const $langfile = @ScriptDir & "\" & $PName & ".lng"
