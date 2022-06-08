import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import System.Environment (getEnv)
import System.FilePath.Posix (takeBaseName)
import System.Directory (getDirectoryContents)
import qualified XMonad.StackSet as W
import GHC.IO.Handle.Types (Handle)

-- Actions

-- Data
import Data.Monoid (All, Endo)
import Data.Map (member)

import Data.Map (member)
import Data.Monoid (All, Endo)
import GHC.IO.Handle.Types (Handle)
import System.Directory (getDirectoryContents)
import System.Environment (getEnv)
import System.Exit (exitSuccess)
import System.FilePath.Posix (takeBaseName)
import System.IO (hPutStrLn)
import XMonad
import XMonad.Actions.CopyWindow (copyToAll, kill1, killAllOtherCopies, wsContainingCopies)
import XMonad.Actions.CycleWS (nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen, toggleWS)
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeWorkspace, renameWorkspaceByName, selectWorkspace, withWorkspace)
import XMonad.Actions.FloatKeys (keysMoveWindow, keysResizeWindow)
import XMonad.Actions.Promote (promote)
import XMonad.Actions.RotSlaves (rotAllDown, rotSlavesDown)
import XMonad.Actions.WorkspaceNames (renameWorkspace, workspaceNamesPP)
-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..), defaultPP, PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.InsertPosition (Focus (Newer), Position (End), insertPosition)
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docksEventHook, manageDocks)
import XMonad.Hooks.ManageHelpers (composeOne, doCenterFloat, doFullFloat, isDialog, isFullscreen)
import XMonad.Hooks.SetWMName (setWMName)
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
-- Layouts

-- Layouts modifiers
import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Layout.MultiToggle (EOT (EOT), Toggle (Toggle), mkToggle, (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (FULL))
import XMonad.Layout.NoBorders (Ambiguity (Screen), lessBorders, smartBorders)
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle (Toggle(Toggle))
import XMonad.Layout.IndependentScreens (countScreens)
import XMonad.Layout.ThreeColumns (ThreeCol (ThreeColMid))
-- Prompt
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch)
import XMonad.Prompt.Pass (passGeneratePrompt, passPrompt)
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Window (WindowPrompt (Bring, Goto), allWindows, windowPrompt, wsWindows)
import qualified XMonad.StackSet as W
-- Utilities

import XMonad.Util.Cursor (setDefaultCursor)
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad (NamedScratchpad (NS), namedScratchpadAction, namedScratchpadManageHook)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce (spawnOnce)

-- TODO runOrRaisePrompt
-- TODO trayer for each screen
main :: IO ()
main = do
    n <- countScreens
    xmprocs <- mapM spawnPipe [ "xmobar -x " ++ show i | i <- [0..n-1] ]
    xmonad $ ewmh def
        { manageHook         = myManageHook
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
        , logHook            = myLogHook xmprocs
        } `additionalKeysP` myKeys

myLogHook :: [Handle] -> X ()
myLogHook procs = mapM_ (\proc -> workspaceNamesPP xmobarPP
    { ppOutput = hPutStrLn proc
    , ppCurrent = xmobarColor white "" . wrap "[" "]"
    , ppVisible = xmobarColor gray "" . wrap "<" ">"
    , ppHidden = xmobarColor gray ""
    , ppUrgent = xmobarColor red "" . wrap "!" "!"
    , ppTitle = xmobarColor green "" . shorten 100
    , ppLayout = xmobarColor white ""
    , ppSep =  "<fc=#555555> :: </fc>"
    , ppOrder  = \(ws:l:t:ex) -> ws : l : t : ex
    } >>= dynamicLogWithPP >> workspaceHistoryHook) procs

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "~/.bin/setup_display"
  spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x0a0d10  --height 22 &"
  spawnOnce "picom --experimental-backends --backend glx -b"
  spawnOnce "flameshot &"
  spawnOnce "dunst &"
  spawnOnce "xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &"
  spawnOnce "xset s 300 5"
  spawnOnce "nm-applet &"
  spawnOnce "xset r rate 200 60 &"
  spawnOnce "sleep 1 && ~/.fehbg"
  spawnOnce "amixer set Master 0%"
  spawnOnce "pkill mpd; mpd &"
  setWMName "LG3D"
  setDefaultCursor xC_left_ptr

myXPConfig :: XPConfig
myXPConfig =
  def
    { font = myFont,
      bgColor = black,
      fgColor = white,
      bgHLight = white,
      fgHLight = black,
      borderColor = magenta,
      promptBorderWidth = 0,
      position = CenteredAt {xpCenterY = 0.3, xpWidth = 0.3},
      height = 40,
      historySize = 0,
      historyFilter = id,
      defaultText = [],
      autoComplete = Just 1,
      showCompletionOnTab = False,
      searchPredicate = fuzzyMatch,
      alwaysHighlight = True,
      maxComplRows = Just 4
    }

-- Layouts
mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing w = spacingRaw True (Border w w w w) True (Border w w w w) True

myLayoutHook =
  avoidStruts $
    smartBorders $
      lessBorders Screen $
        mkToggle (FULL ?? EOT) $
          tall ||| columns ||| full
  where
    tall =
      renamed [Replace "tall"] $
        mySpacing 8 $
          reflectHoriz $
            Tall 1 (1 / 20) (1 / 2)

    columns =
      renamed [Replace "cols"] $
        mySpacing 8 $
          reflectHoriz $
            ThreeColMid 1 (1 / 20) (3 / 5)

    full =
      renamed [Replace "full"] $
        Full

-- Workspaces
myWorkspaces :: [String]
myWorkspaces = map show [1 .. 9]

-- Scratchpads
myScratchpads :: [NamedScratchpad]
myScratchpads =
  [ NS "term" spawnTerm findTerm doCenterFloat,
    NS "calc" spawnCalc findCalc doCenterFloat,
    NS "pavu" spawnPavu findPavu doCenterFloat,
    NS "music" spawnMusic findMusic doCenterFloat,
    NS "files" spawnFileManager findFileManager doCenterFloat
  ]
  where
    spawnTerm = myTerminal ++ " start --class scratchpad"
    findTerm = className =? "scratchpad"

    spawnCalc = "qalculate-gtk"
    findCalc = className =? "Qalculate-gtk"

    spawnPavu = "pavucontrol"
    findPavu = className =? "Pavucontrol"

    spawnMusic = myTerminal ++ " -t ncmpcpp -e ncmpcpp"
    findMusic = title =? "ncmpcpp"

    spawnFileManager = myFileManager
    findFileManager = className =? "Pcmanfm"

-- Manage hook
myManageHook :: ManageHook
myManageHook =
  manageApps
    <+> manageDocks
    <+> namedScratchpadManageHook myScratchpads
  where
    -- tileEnd = insertPosition End Newer
    manageApps :: XMonad.Query (Endo WindowSet)
    manageApps =
      composeAll . concat $
        [ [className =? "brave" --> doShift (myWorkspaces !! 0)],
          [className =? "postman" --> doShift (myWorkspaces !! 3)],
          [className =? "jetbrains-datagrip" --> doShift (myWorkspaces !! 4)],
          [className =? "Slack" --> doShift (myWorkspaces !! 8)],
          [className =? "discord" --> doShift (myWorkspaces !! 8)],
          [className =? c --> doCenterFloat | c <- myFloatsC],
          [title =? t --> doCenterFloat | t <- myFloatsT],
          [title =? t --> doFloat <+> doF copyToAll | t <- myStickyFloats],
          [isFullscreen --> doFullFloat],
          [isDialog --> doCenterFloat],
          [(stringProperty "WM_WINDOW_ROLE") =? "pop-up" --> doFloat]
        ]
      where
        myFloatsC = ["Pcmanfm", "Xarchiver", "KeePassXC", "Lxappearance", "nm-connection-editor", "feh"]
        myFloatsT = ["Ghidra: NO ACTIVE PROJECT"]
        myStickyFloats = ["Picture in picture"]

-- Custom functions
toggleGlobal :: X ()
toggleGlobal = do
  ws <- wsContainingCopies
  if null ws
    then windows copyToAll
    else killAllOtherCopies

centerWindow :: Window -> X ()
centerWindow win = do
  (_, W.RationalRect x y w h) <- floatLocation win
  windows $ W.float win (W.RationalRect ((1 - w) / 2) ((1 - h) / 2) w h)
  return ()

toggleFloat :: Window -> X ()
toggleFloat w =
  windows
    ( \s ->
        if member w (W.floating s)
          then W.sink w s
          else (W.float w (W.RationalRect (1 / 3) (1 / 4) (1 / 3) (1 / 2)) s)
    )

data Script = Script

instance XPrompt Script where
  showXPrompt Script = "Script: "
  commandToComplete _ c = c
  nextCompletion _ = getNextCompletion

scriptsPrompt :: XPConfig -> X ()
scriptsPrompt c = do
  scripts <- io getScripts
  mkXPrompt Script c (mkComplFunFromList scripts) selectScript

selectScript :: String -> X ()
selectScript s = spawn $ "notify-send " ++ s

getScripts :: IO [String]
getScripts = do
  user <- getEnv "USER"
  entries <- getDirectoryContents $ "/home/" ++ user ++ "dev/scripts"
  -- return entries
  return $ map takeBaseName entries

-- Keybindings
myKeys :: [(String, X ())]
myKeys =
  [ ("M-S-r", spawn "xmonad --recompile && xmonad --restart && notify-send 'XMonad restarted'"),
    -- Apps
    ("M-<Return>", spawn myTerminal),
    -- Scratchpads
    ("M-s", namedScratchpadAction myScratchpads "term"),
    ("M-q", namedScratchpadAction myScratchpads "calc"),
    ("M-v", namedScratchpadAction myScratchpads "pavu"),
    ("M-m", namedScratchpadAction myScratchpads "music"),
    ("M-e", namedScratchpadAction myScratchpads "files"),
    ("M-g", windowPrompt myXPConfig Goto allWindows),
    ("M-b", windowPrompt myXPConfig Bring allWindows),
    -- Launchers
    ("M-p", shellPrompt myXPConfig),
    ("M-n", scriptsPrompt myXPConfig),
    ("M-<Space>", passPrompt myXPConfig),
    ("M-S-<Space>", passGeneratePrompt myXPConfig),
    -- Misc
    ("M-y", spawn "color-picker"),
    ("M-u", spawn "toggle-keymap"),
    ("M-S-l", spawn "xset s activate"),
    -- Media
    ("<XF86AudioMute>", spawn "amixer set Master toggle"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute"),
    ("M-C-t", spawn "mpc toggle"),
    ("M-C-p", spawn "mpc prev"),
    ("M-C-n", spawn "mpc next"),
    -- Focus
    ("M-j", windows W.focusDown), -- Move focus to the next window
    ("M-k", windows W.focusUp), -- Move focus to the prev window
    ("M-S-j", windows W.swapDown), -- Swap focused window with next window
    ("M-S-k", windows W.swapUp), -- Swap focused window with prev window
    -- , ("M-m",    windows W.focusMaster)                              -- Move focus to the master window

    -- Move windows
    ("M-<Backspace>", promote), -- Moves focused window to master
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack
    ("M-c", withFocused centerWindow), -- Center window TODO: center only if floating
    ("M-f", withFocused toggleFloat), -- Push floating window to tile
    ("M-<Left>", withFocused (keysMoveWindow (-windowStep, 0))),
    ("M-<Down>", withFocused (keysMoveWindow (0, windowStep))),
    ("M-<Right>", withFocused (keysMoveWindow ((windowStep), 0))),
    ("M-<Up>", withFocused (keysMoveWindow (0, -windowStep))),
    ("M-S-<Left>", withFocused (keysResizeWindow (-windowStep, 0) (0, 0))),
    ("M-S-<Down>", withFocused (keysResizeWindow (0, windowStep) (0, 0))),
    ("M-S-<Right>", withFocused (keysResizeWindow ((windowStep), 0) (0, 0))),
    ("M-S-<Up>", withFocused (keysResizeWindow (0, -windowStep) (0, 0))),
    -- Control windows
    ("M-S-c", kill1), -- Kill the currently focused window
    ("M-o", toggleGlobal), -- Copy a window to other workspaces or remove it if already present

    -- Resizing
    ("M-h", sendMessage Expand), -- Shrink horiz window width
    ("M-l", sendMessage Shrink), -- Expand horiz window width

    -- Screen handling
    ("M-,", prevScreen), -- Move focus to previous screen
    ("M-.", nextScreen), -- Move focus to next screen
    ("M-S-,", shiftNextScreen), -- Move focused window to previous screen
    ("M-S-.", shiftPrevScreen), -- Move focused window to next screen
    ("M-<Tab>", toggleWS), -- Move to last workspace

    -- Layouts
    ("M-z", sendMessage NextLayout), -- Switch to next layout
    ("M-S-f", sendMessage (Toggle FULL) >> sendMessage ToggleStruts), -- Toggles fullscreen

    -- Workspaces handling
    ("M-a", addWorkspacePrompt myXPConfig), -- Create a workspace
    ("M-d", removeWorkspace), -- Delete a workspace
    ("M-w", selectWorkspace myXPConfig), -- Go to a workspace
    ("M-r", renameWorkspace myXPConfig), -- Rename a workspace
    ("M-S-s", withWorkspace myXPConfig (windows . W.shift)) -- Shift current window to a workspace
  ]

-- Variables
myFont :: String
myFont = "xft:JetBrains Mono:Medium:size=11"

myModMask :: KeyMask
myModMask = mod1Mask

myTerminal :: String
myTerminal = "wezterm"

myFileManager :: String
myFileManager = "pcmanfm"

myBorderWidth :: Dimension
myBorderWidth = 2

myNormColor :: String
myNormColor = gray

myFocusColor :: String
myFocusColor = red

black :: String
black = "#0a0d10"

white :: String
white = "#e6e8ee"

red :: String
red = "#ff5555"

green :: String
green = "#55ff55"

magenta :: String
magenta = "#ff55ff"

cyan :: String
cyan = "#55ffff"

gray :: String
gray = "#555555"

windowStep :: Dimension
windowStep = 50
