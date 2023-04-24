# SETBACK-Z80
Videogame made for Amstrad CPC RetroDev contest by TCore team, in Z80 assembly language using CPCtelera framework.
<br>
See the full game [here](https://www.youtube.com/watch?v=L9W-DnKUrTQ "Walkthrough").
<br>
Download the video game on the official [page](http://cpcretrodev.byterealms.com/contest-en/cpcretrodev-2020-2/).

***

## TCore members:
* Alejandro Castro Valero
* Juan Carlos Soria Salto
* Gabriel Martínez Antón

***

## Requirements
* **CPCtelera** framework
* **Windows**, **Linux** and **OSX** operating system

***

## Compilation
* `cd game`
* `make`
  * `setback.cdt` emulates an amstrad cassette
  * `setback.dsk` disk file
  * `setback.sna` snapshot
* `cpct_winape setback.sna` | `cpct_winape setback.dsk` | `cpct_rvm setback.cdt` execution

***

## Controls
The gamepad can be used to play in-game. To navigate throughout the menu, the keyboard is needed.

### Keyboard
* Menu
  * `SPACE` continue
  * `C` credits
* Game
  * `O` Move left
  * `P` Move right
  * `Q` Jump
  * `ESC` Pause
### Gamepad
* Game
  * `LEFT` Joystick move left
  * `RIGHT` Joystick move right
  * `BUTTON 1` Jump

***

## Screenshots
<img src="https://github.com/AlejandroDCastro/SETBACK-Z80/blob/main/game/pics/menu_ingame.png" alt="Menu" width="500">&nbsp;<img src="https://github.com/AlejandroDCastro/SETBACK-Z80/blob/main/game/pics/ingame1.png" alt="Picture 1" width="470">
<br>
<img src="https://github.com/AlejandroDCastro/SETBACK-Z80/blob/main/game/pics/ingame2.png" alt="Picture 2" width="500">
