{-# LANGUAGE OverloadedStrings #-}

-- Base
import Control.Monad (when)
import Data.Maybe (isJust)
import Data.Tree
import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad
-- Actions
import XMonad.Actions.CycleWS ()
import XMonad.Actions.DynamicProjects
import XMonad.Actions.GridSelect
import XMonad.Actions.TreeSelect
-- Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.WorkspaceHistory ()
-- Layouts
import XMonad.Layout.Gaps
import XMonad.Layout.Column
import XMonad.Layout.Grid
import XMonad.Layout.SimpleFloat
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Roledex
import XMonad.Layout.Spacing (Border (..), spacingRaw)
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
-- Prompts
import XMonad.Prompt (XPConfig (..))
import XMonad.Prompt.Input
import XMonad.Prompt.Pass
import XMonad.Prompt.Unicode
import XMonad.Prompt.Workspace
import XMonad.Prompt.XMonad
import qualified XMonad.StackSet as W
-- Util
import XMonad.Util.Paste
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run 
import XMonad.Util.Themes
import XMonad.Util.WorkspaceCompare

-- PulseAudio Headset
-- headsetSink = "alsa_input.usb-Logitech_G533_Gaming_Headset-00.mono-fallback"
headsetSink :: String
headsetSink = "alsa_input.pci-0000_0b_00.4.analog-stereo"

-- Scratchpads
myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "mixer" spawnMixer findMixer manageMixer,
    NS "popup" spawnPopup findPopup managePopup
  ]
  where
    spawnMixer = "urxvt -title Pulsemixer -name Pulsemixer -e pulsemixer" -- launch pulsemixer
    findMixer = resource =? "Pulsemixer" -- its window will be named "pulsemixer"
    manageMixer = customFloating $ W.RationalRect l t w h -- and the geometry:
      where
        h = 0.2
        w = 0.8
        t = 0.5 - (h / 2)
        l = 0.5 - (w / 2)

    spawnPopup = "urxvt -title tmux -name popup"
    findPopup = resource =? "popup"
    managePopup = customFloating $ W.RationalRect l t w h -- and the geometry:
      where
        h = 0.7
        w = 0.7
        t = 0.5 - (h / 2)
        l = 0.5 - (w / 2)


-- Keybindings
extraKeys :: [((KeyMask, KeySym), X ())]
extraKeys =
  foldr1
    (++)
    [ [ -- Workspace Navigation
        ((mod4Mask, xK_f), spawn "rofi -show window -theme 'Arc-Dark'")
      ],
      [ -- Spawn Programs
        ((mod4Mask .|. shiftMask, xK_Return), namedTerminal),
        ((mod4Mask, xK_p), spawn "rofi -show run -theme 'Arc-Dark'"),
        ((mod4Mask .|. shiftMask, xK_p), spawn "rofi -show window -theme 'Arc-Dark'"),
        ((mod4Mask, xK_g), sendMessage ToggleGaps)
      ],
      [ -- XMonad Config
        ((mod4Mask .|. shiftMask, xK_t), sendMessage ToggleStruts)
      ],
      [ -- Screenshots
        ((mod4Mask, xK_s), screenshot),
        ((mod4Mask .|. shiftMask, xK_s), screenshotWindow)
      ],
      [ -- Date
        ((mod4Mask, xK_d), insertDate)
      ],
      [ -- Scratchpad
        ((mod4Mask, xK_m), namedScratchpadAction myScratchPads "mixer"),
        ((mod4Mask, xK_c), namedScratchpadAction myScratchPads "popup")
      ],
      [ -- XMonad.Prompt
        ((mod4Mask .|. controlMask, xK_o), unicodePrompt "/home/djanatyn/UnicodeData.txt" (def {font = "xft:Noto Color Emoji"})),
        ((mod4Mask .|. controlMask, xK_p), passPrompt def),
        ((mod4Mask, xK_c), namedScratchpadAction myScratchPads "clock")
      ]
    ]

insertDate :: X ()
insertDate = inputPrompt def "date?" >>= launch
  where
    launch (Just date) = 
      let cmd = "date -d '" ++ date ++ "' --rfc-3339=seconds | perl -pe 's/ /T/'" in do
        timestamp <- runProcessWithInput "bash" ["-c", cmd] ""
        pasteString $ "<time:" ++ timestamp ++ ">"
    launch Nothing = return ()

screenshot :: X ()
screenshot = inputPrompt def "screenshot name?" >>= launch
  where
    launch (Just name) = spawn $ unwords ["/home/djanatyn/.xmonad/screenshot.sh", name]
    launch Nothing = return ()

screenshotWindow :: X ()
screenshotWindow = inputPrompt def "screenshot name?" >>= launch
  where
    launch (Just name) = spawn $ unwords ["/home/djanatyn/.xmonad/screenshot-window.sh", name]
    launch Nothing = return ()

-- Prompt for terminal names
namedTerminal :: X ()
namedTerminal = inputPrompt def "terminal name?" >>= launch
  where
    launch (Just name) = spawn $ "kitty --title " ++ name
    launch Nothing = return ()

-- Layouts
spacing = spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True

tall = Tall 1 (3 / 100) (1 / 2)

column = Column (10 / 7)

mediaLayout = Column 3

defaultLayout = tall ||| Full ||| column ||| ThreeCol 1 (3/100) (1/2) ||| simpleFloat

myLayout =
  avoidStruts $ spacing $ gaps' [((L, 400), True), ((R, 400), True)] defaultLayout

-- Fade
myFadeHook :: FadeHook
myFadeHook =
  composeAll
    [ opaque,
      -- unfocused windows are no longer transparent
      isUnfocused --> opacity 1,
      isUnfocused --> opacity 1,
      -- Leave emacs mostly opaque
      resource =? "popup" --> opacity 0.9,
      className =? "Emacs-27.1" --> opacity 0.9,
      className =? "webex" --> opacity 0.9,
      className =? "Firefox" --> opacity 1,
      className =? "explorer.exe" --> opacity 1
    ]


startupProcs :: [String]
startupProcs =
  [ "nitrogen --restore",
    "picom",
    "~/.screenlayouts/default.sh",
    "fluxgui"
  ]

-- Main
main :: IO ()
main = do
  xmobarProc <- spawnPipe "xmobar -o"
  spawn `traverse` startupProcs
  xmonad $
    ewmh $
      -- dynamicProjects myProjects $
      (defaults xmobarProc)
        `additionalKeys` extraKeys

defaults xmobarProc =
  def
    { logHook =
        composeAll
          [ fadeWindowsLogHook myFadeHook,
            dynamicLogWithPP $
              xmobarPP
                { ppOutput = hPutStrLn xmobarProc,
                  ppExtras = [loadAvg, battery],
                  ppSort = getSortByXineramaRule
                }
          ],
      manageHook = manageDocks <+> manageHook def <+> namedScratchpadManageHook myScratchPads,
      -- workspaces = myWorkspaces,
      layoutHook = myLayout,
      handleEventHook =
        composeAll
          [ handleEventHook def,
            docksEventHook,
            fadeWindowsEventHook
          ],
      borderWidth = 1,
      terminal = "kitty",
      normalBorderColor = "#264653",
      focusedBorderColor = "#2a9d8f",
      focusFollowsMouse = False,
      modMask = mod4Mask
    }
