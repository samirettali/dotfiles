-- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
import GHC.IO.Handle.Types (Handle)

-- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (nextScreen, prevScreen, toggleWS, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.Promote (promote)
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.CopyWindow (copyToAll, wsContainingCopies)

-- Data
import Data.Monoid (All, Endo)

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat, isDialog)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Hooks.InsertPosition (insertPosition, Position(End), Focus(Newer))

-- Layouts
import XMonad.Layout.ThreeColumns (ThreeCol(ThreeColMid))
import XMonad.Layout.Reflect (reflectHoriz)

-- Layouts modifiers
import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Layout.MultiToggle (mkToggle, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle (Toggle(Toggle))

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch)
import XMonad.Prompt.Shell (shellPrompt)

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.NamedScratchpad (NamedScratchpad(NS), namedScratchpadManageHook, namedScratchpadAction)
import XMonad.Util.Cursor (setDefaultCursor)

-- TODO trayer for each screen
-- TODO launch xmobar on all displays
main :: IO ()
main = do
    -- n <- countScreens
    xmproc <- spawnPipe "xmobar"
    xmonad $ ewmh def
        { manageHook = myManageHook
        , handleEventHook    = docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , focusFollowsMouse  = True
        , logHook            = myLogHook xmproc
        } `additionalKeysP` myKeys

myLogHook :: Handle -> X ()
myLogHook proc = workspaceHistoryHook <+> dynamicLogWithPP xmobarPP
    { ppOutput = hPutStrLn proc
    , ppCurrent = xmobarColor white ""
    , ppVisible = xmobarColor gray ""
    , ppHidden = xmobarColor gray ""
    , ppUrgent = xmobarColor red "" . wrap "!" "!"
    , ppTitle = xmobarColor green "" . shorten 100
    , ppLayout = xmobarColor white ""
    , ppSep =  "<fc=#555555> :: </fc>"
    , ppOrder  = \(ws:l:t:ex) -> ws : l : t : ex
    }

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
    spawnOnce "sleep 1 && ~/.fehbg"
    spawnOnce "amixer set Master 0%"
    spawnOnce "mpd &"
    setWMName "LG3D"
    setDefaultCursor xC_left_ptr

myXPConfig :: XPConfig
myXPConfig = def
    { font                = myFont
    , bgColor             = black
    , fgColor             = white
    , bgHLight            = black
    , fgHLight            = magenta
    , borderColor         = magenta
    , promptBorderWidth   = myBorderWidth
    , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
    , height              = 40
    , historySize         = 256
    , historyFilter       = id
    , defaultText         = []
    , autoComplete        = Just 1
    , showCompletionOnTab = False
    , searchPredicate     = fuzzyMatch
    , alwaysHighlight     = True
    , maxComplRows        = Just 4
    }

-- Layouts
mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing w = spacingRaw True (Border w w w w) True (Border w w w w) True

myLayoutHook =
    avoidStruts $
    smartBorders $
    mkToggle (NBFULL ?? EOT) $
    tall ||| columns ||| full
  where
    tall = renamed [Replace "tall"]
        $ mySpacing 8
        $ reflectHoriz
        $ Tall 1 (1/20) (1/2)

    full = renamed [Replace "full"]
      $ Full

    columns = renamed [Replace "cols"]
        $ mySpacing 8
        $ reflectHoriz
        $ ThreeColMid 1 (1/20) (3/5)

-- Workspaces
myWorkspaces :: [String]
myWorkspaces = map show [1..9]

-- Scratchpads
myScratchpads :: [NamedScratchpad]
myScratchpads =
    [ NS "term" spawnTerm findTerm doCenterFloat
    , NS "calc" spawnCalc findCalc doCenterFloat
    , NS "pavu" spawnPavu findPavu doCenterFloat
    , NS "music" spawnMusic findMusic doCenterFloat
    ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad -e tmux new -A -s scratchpad"
    findTerm   = title =? "scratchpad"

    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"

    spawnPavu = "pavucontrol"
    findPavu = (className =? "Pavucontrol")

    spawnMusic  = myTerminal ++ " -t ncmpcpp -e ncmpcpp"
    findMusic   = title =? "ncmpcpp"

-- Manage hook
myManageHook :: ManageHook
myManageHook = manageApps
    <+> manageDocks
    <+> namedScratchpadManageHook myScratchpads
  where
    tileEnd = insertPosition End Newer
    manageApps :: XMonad.Query (Endo WindowSet)
    manageApps = composeAll . concat $
        [ [ className =? "brave"           --> doShift (myWorkspaces !! 0) ]
        , [ className =? "Code"            --> doShift (myWorkspaces !! 1) ]
        , [ className =? "jetbrains-rider" --> doShift (myWorkspaces !! 1) ]
        , [ className =? "Slack"           --> doShift (myWorkspaces !! 8) ]
        , [ className =? "discord"         --> doShift (myWorkspaces !! 8) ]
        , [ className =? c --> doCenterFloat | c <- myFloatsC ]
        , [ title =?     t --> doFloat <+> doF copyToAll | t <- myStickyFloats ]
        -- , [ isFullscreen --> doFullFloat ]
        , [ pure True --> tileEnd ]
        ]
      where
        myFloatsC = ["Pcmanfm", "Xarchiver", "KeePassXC", "Lxappearance"]
        myStickyFloats = ["Picture in picture"]

-- Custom functions
toggleGlobal :: X ()
toggleGlobal = do
    ws <- wsContainingCopies
    if null ws
    then windows copyToAll
    else killAllOtherCopies

-- Keybindings
myKeys :: [(String, X ())]
myKeys =
    [ ("M-r", spawn "xmonad --recompile && xmonad --restart && notify-send 'XMonad restarted'")

    -- Apps
    , ("M-<Return>", spawn myTerminal)
    , ("M-C-m",      spawn $ myTerminal ++ " -e ncmpcpp")
    , ("M-e",        spawn myFileManager)

    -- Scratchpads
    , ("M-s", namedScratchpadAction myScratchpads "term")
    , ("M-q", namedScratchpadAction myScratchpads "calc")
    , ("M-a", namedScratchpadAction myScratchpads "pavu")
    , ("M-m", namedScratchpadAction myScratchpads "music")

    -- Launchers
    , ("M-p",          spawn "rofi-pass")
    , ("M-<Space>",    shellPrompt myXPConfig)

    -- Misc
    , ("M-y", spawn "color-picker")
    , ("M-u", spawn "toggle-keymap")

    -- Media
    , ("<XF86AudioMute>",        spawn "amixer set Master toggle")
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
    , ("M-C-t",                  spawn "mpc toggle")
    , ("M-C-p",                  spawn "mpc prev")
    , ("M-C-n",                  spawn "mpc next")

    -- Focus
    , ("M-j",   windows W.focusUp)                                         -- Move focus to the next window
    , ("M-k",   windows W.focusDown)                                       -- Move focus to the prev window
    , ("M-S-j", windows W.swapDown)                                        -- Swap focused window with next window
    , ("M-S-k", windows W.swapUp)                                          -- Swap focused window with prev window
    -- , ("M-m",    windows W.focusMaster)                                 -- Move focus to the master window

    -- Move windows
    , ("M-<Backspace>", promote)                                           -- Moves focused window to master
    , ("M-S-<Tab>",     rotSlavesDown)                                     -- Rotate all windows except master and keep focus in place
    , ("M-C-<Tab>",     rotAllDown)                                        -- Rotate all the windows in the current stack
    , ("M-t",           withFocused $ windows . W.sink)                    -- Push floating window to tile

    -- Control windows
    , ("M-w", kill1)                                                       -- Kill the currently focused window
    , ("M-o", toggleGlobal)                                                -- Copy a window to other workspaces or remove it if already present

    -- Resizing
    , ("M-h", sendMessage Expand)                                          -- Shrink horiz window width
    , ("M-l", sendMessage Shrink)                                          -- Expand horiz window width

    -- Screen handling
    , ("M-,",     prevScreen)                                              -- Move focus to previous screen
    , ("M-.",     nextScreen)                                              -- Move focus to next screen
    , ("M-S-,",   shiftNextScreen)                                         -- Move focused window to previous screen
    , ("M-S-.",   shiftPrevScreen)                                         -- Move focused window to next screen
    , ("M-<Tab>", toggleWS)                                                -- Move to last workspace

    -- Layouts
    , ("M-z", sendMessage NextLayout)                                      -- Switch to next layout
    , ("M-i", sendMessage (IncMasterN 1))                                  -- Increase number of clients in master pane
    , ("M-d", sendMessage (IncMasterN (-1)))                               -- Decrease number of clients in master pane
    , ("M-f", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts)  -- Toggles fullscreen

    -- WORKSPACE CONTROL
    -- , ("M-n", addWorkspacePrompt myXPConfig)                                             -- Decrease number of windows
    -- , ("-S-d", removeWorkspace)                                                         -- Decrease number of windows
    {- , ("M-'", selectWorkspace myXPConfig)                                                -- Decrease number of windows
    , ("M-S-'", withWorkspace myXPConfig (windows . W.shift) ) -}
    -- , ("M-u", renameWorkspace)
    ]

-- Default settings
myFont :: String
myFont = "xft:JetBrains Mono:Medium:size=11"

myModMask :: KeyMask
myModMask = mod1Mask

myTerminal :: String
myTerminal = "alacritty"

myFileManager :: String
myFileManager = "pcmanfm"

myBorderWidth :: Dimension
myBorderWidth = 1

myNormColor :: String
myNormColor = gray

myFocusColor :: String
myFocusColor  = magenta

black :: String
black = "#0a0d10"

white :: String
white = "#e6e8ee"

red :: String
red = "#ff5555"

green :: String
green = "#55ff55"

magenta :: String
magenta = "#bd93f9"

cyan :: String
cyan = "#55ffff"

gray :: String
gray = "#434c5e"
