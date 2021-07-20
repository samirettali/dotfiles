-- TODO workspaceNamesPP
-- TODO trayer for each screen
-- TODO improve xmobar for each screen

-- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, toggleWS, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.FloatKeys
import XMonad.Actions.WorkspaceNames (renameWorkspace)
import XMonad.Actions.DynamicWorkspaces

-- Data
import Data.Char (isSpace)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.ToggleHook
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)

-- Layouts
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Reflect
import XMonad.Layout.LayoutCombinators (JumpToLayout(..))
import XMonad.Layout.IndependentScreens

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders (Ambiguity(Screen), smartBorders, lessBorders)
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.Spacing
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.XMonad
import Control.Arrow (first)

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Loggers

--------------------------------------------------------------------------------------
-------------------------- DEFAULTS SETTINGS / APPS ----------------------------------
--------------------------------------------------------------------------------------

black :: String
black = "#000000"

white :: String
white = "#ffffff"

red :: String
red = "#ff5555"

green :: String
green = "#55ff55"

yellow :: String
yellow = "#ffff55"

blue :: String
blue = "#5555ff"

magenta :: String
magenta = "#ff55ff"

cyan :: String
cyan = "#55ffff"

gray :: String
gray = "#555555"

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:Medium:size=11.5:regular:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod1Mask            -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"               -- Sets default terminal

myBrowser :: String
myBrowser = "brave "            -- Sets qutebrowser as browser for tree select

myFileManager :: String
myFileManager = "pcmanfm"       -- Sets pcmanfm as file manager

myEditor :: String
myEditor = myTerminal ++ " -e nvim"  -- Sets neovim as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 2               -- Sets border width for windows

myNormColor :: String
myNormColor = "#2c425c"              -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#9dbadf"             -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask              -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


--------------------------------------------------------------------------------------
-------------------------------- XMONAD STARTUP --------------------------------------
--------------------------------------------------------------------------------------

myStartupHook :: X ()
myStartupHook = do
          spawnOnce "eval $(ssh-agent) &"
          spawnOnce "~/.bin/setup_display"
          spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x000000  --height 22 &"
          spawnOnce "picom --experimental-backends --backend glx -b"
          spawnOnce "flameshot &"
          spawnOnce "dunst &"
          spawnOnce "xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &"
          spawnOnce "xset s 300 5"
          spawnOnce "nm-applet &"
          spawnOnce "xset r rate 200 60 &"
          spawnOnce "xsetroot -cursor_name left_ptr &"
          spawnOnce "sleep 1 && ~/.fehbg"
          spawnOnce "amixer set Master 0%"
          setWMName "LG3D"

--------------------------------------------------------------------------------------
-------------------------------- RUN PROMPT THEME ------------------------------------
--------------------------------------------------------------------------------------

myXPConfig :: XPConfig
myXPConfig = def
      { font                = myFont
      , bgColor             = black
      , fgColor             = white
      , bgHLight            = white
      , fgHLight            = black
      , borderColor         = red
      , promptBorderWidth   = 2
      , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
      , height              = 40
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 100000  -- set Just 100000 for .1 sec
      , showCompletionOnTab = False
      , searchPredicate     = fuzzyMatch
      , alwaysHighlight     = True
      , maxComplRows        = Just 7
      }

--------------------------------------------------------------------------------------
------------------------------ PER-LAYOUT SETTINGS -----------------------------------
--------------------------------------------------------------------------------------

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing w = spacingRaw True (Border w w w w) True (Border w w w w) True
-- mySpacing w = spacingRaw False (Border w w w w) True (Border w w w w) False

--- LAYOUT

tall      = renamed [Replace "tall"]
           $ reflectHoriz
           $ mySpacing 8
           $ ResizableTall 1 (1/20) (6/10) []

monocle  = renamed [Replace "monocle"]
           $ Full

columns  = renamed [Replace "columns"]
           $ mySpacing 8
           $ ThreeColMid 1 (1/20) (6/10)

-- LAYOUT HOOK
myLayouts = tall ||| columns ||| monocle
myLayoutHook = avoidStruts $
                mouseResize $
                windowArrange $
                smartBorders $
                lessBorders Screen $
                mkToggle (NBFULL ?? NOBORDERS ?? EOT) myLayouts

--------------------------------------------------------------------------------------
------------------------------------ WORKSPACES --------------------------------------
--------------------------------------------------------------------------------------

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
-- myWorkspaces = withScreens 2
myWorkspaces = clickable . (map xmobarEscape)
               $["1", "2", "3", "4", "5", "6", "7", "8", "9"]
               where
                        clickable l = [ "<action=xdotool key alt+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                             (i,ws) <- zip [1..9] l,                                        
                            let n = i ]

--------------------------------
-- CUSTOM PER WINDOW SETTINGS --
--------------------------------
--
role :: Query String
role = stringProperty "WM_WINDOW_ROLE"

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [ className =? "brave"           --> doShift (myWorkspaces !! 0)
     , className =? "Code"            --> doShift (myWorkspaces !! 1)
     , className =? "jetbrains-rider" --> doShift (myWorkspaces !! 1)
     , className =? "Slack"           --> doShift (myWorkspaces !! 8)
     , className =? "discord"         --> doShift (myWorkspaces !! 8)
     , className =? "Pcmanfm"         --> doCenterFloat
     , className =? "KeePassXC"       --> doCenterFloat
     , title     =? "Scratchpad"      --> doCenterFloat
     , title     =? "ranger"          --> doCenterFloat
     , role      =? "pop-up"          --> doCenterFloat
     ]

-----------------
-- KEYBINDINGS --
-----------------

myKeys :: [(String, X ())]
myKeys =
        -- XMONAD
        [ ("M-C-r", spawn "xmonad --recompile")                                              -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart && notify-send 'Xmonad Recompiled'")             -- Restarts xmonad

        -- TERMINAL
        , ("M-<Return>", spawn (myTerminal))
        , ("M-C-<Return>", spawn (myTerminal ++ " -t Scratchpad"))
        , ("M-C-n", spawn (myTerminal ++ " -e ncmpcpp"))
        , ("M-e", spawn (myTerminal ++ " -e nvim"))
        , ("M-f", spawn (myFileManager))

        -- MENU
        , ("M-p",     shellPrompt myXPConfig)                                                -- Shell Prompt
        , ("M-<Tab>", toggleWS)                                                              -- Toggle last workspace

        -- MISC
        , ("M-y", spawn "color-picker")
        , ("M-u", spawn "setxkbmap -query | grep -q 'us' && setxkbmap it || setxkbmap us")

        -- VOLUME
        , ("<XF86AudioMute>",        spawn "amixer set Master toggle")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86AudioPlay>",        spawn "mpc toggle")
        , ("<XF86AudioPrev>",        spawn "mpc prev")
        , ("<XF86AudioNext>",        spawn "mpc next")


        -- WINDOW
        , ("M-S-c", kill1)                                                                   -- Kill the currently focused client
        -- , ("M-S-a", killAll)                                                              -- Kill all windows on current workspace

        -- FLOAT LAYOUT
        , ("M-S-f", withFocused $ windows . W.sink)                                          -- Push floating window to tile
        , ("M-s", spawn "selected=$(ls --color=never ~/work/young/scripts/|rofi -dmenu -p 'Run: ') && bash ~/work/young/scripts/${selected}")

        --Keybindings
        , ("M-t" , sendMessage $ JumpToLayout "tall"    )
        -- , ("M-f" , sendMessage $ JumpToLayout "full"     )
        -- , ("M-c" , sendMessage $ JumpToLayout "columns"     )

        -- WINDOW NAVIGATION
        , ("M-m", windows W.focusMaster)                                                     -- Move focus to the master window
        , ("M-j", windows W.focusUp)                                                         -- Move focus to the next window
        , ("M-k", windows W.focusDown)                                                       -- Move focus to the prev window
        , ("M-S-j", windows W.swapDown)                                                      -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)                                                        -- Swap focused window with prev window
        , ("M-<Backspace>", promote)                                                         -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)                                                       -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)                                                          -- Rotate all the windows in the current stack
        , ("M-C-s", killAllOtherCopies)

        , ("M-,", prevScreen)
        , ("M-.", nextScreen)
        , ("M-S-,", shiftNextScreen)
        , ("M-S-.", shiftPrevScreen)

        -- LAYOUT KEY
        , ("M-z", sendMessage NextLayout)                                                    -- Switch to next layout
        , ("M-C-M1-<Up>", sendMessage Arrange)
        , ("M-C-M1-<Down>", sendMessage DeArrange)
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)          -- Toggles noborder/full
        , ("M-i", sendMessage (IncMasterN 1))                                                -- Increase number of clients in master pane
        , ("M-d", sendMessage (IncMasterN (-1)))                                             -- Decrease number of clients in master pane

        , ("M-n", addWorkspacePrompt myXPConfig)                                             -- Decrease number of windows
        , ("M-S-d", removeWorkspace)                                                         -- Decrease number of windows
        , ("M-'", selectWorkspace myXPConfig)                                                -- Decrease number of windows
        , ("M-S-'", withWorkspace myXPConfig (windows . W.shift) )
        -- , ("M-u", renameWorkspace)


        -- RESIZING
        , ("M-h", sendMessage Expand)                                                        -- Shrink horiz window width
        , ("M-l", sendMessage Shrink)                                                        -- Expand horiz window width
        , ("M-C-j", sendMessage MirrorShrink)                                                -- Shrink vert window width
        , ("M-C-k", sendMessage MirrorExpand)                                                -- Expand vert window width

        -- SCRIPTS
        -- , ("M-u s", spawn "bash ~/.bin/setup_display")
        , ("M-S-l", spawn "xset s activate")
      ]


main :: IO ()
main = do
    n <- countScreens
    xmproc <- spawnPipe "bash -c 'tee >(xmobar -x 1) | xmobar -x 0'"

    -- XMONAD HOOKS
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               <+> docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , focusFollowsMouse  = True
        , logHook            = workspaceHistoryHook <+> dynamicLogWithPP xmobarPP
                              { ppOutput = hPutStrLn xmproc
                              , ppCurrent = xmobarColor white ""                             -- Current workspace in xmobar
                              , ppVisible = xmobarColor gray ""                              -- Visible but not current workspace
                              , ppHidden = xmobarColor gray ""                               -- Hidden workspaces in xmobar
                              , ppTitle = xmobarColor green "" . shorten 100                 -- Title of active window in xmobar
                              , ppLayout = xmobarColor white ""
                              , ppSep =  "<fc=#555555> | </fc>"                              -- Separators in xmobar
                              , ppUrgent = xmobarColor red "" . wrap "!" "!"                 -- Urgent workspace
                              , ppOrder  = \(ws:l:t:ex) -> ws : l : t : ex
                              }
        } `additionalKeysP` myKeys
