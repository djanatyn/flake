{ pkgs }:
with pkgs; {
  system = [
    # tools you can't live without
    direnv
    bubblewrap
    man-pages
    man-pages-posix
    btop
    rsync
    rclone
    which
    file
    binutils
    moreutils
    pueue
    broot
    epr
    visidata
    epr

    # downloading
    aria2

    # classics get an upgrade
    htop
    glances
    bat
    mdcat
    procs
    exa

    # timer!
    termdown
    peaclock

    # conversions
    fend

    # checking scripts
    shellcheck

    # management
    home-manager
    pueue

    # graphics
    graphviz

    # dotfiles
    stow

    # graphics
    graphviz
  ];

  network = [
    # dig
    dnsutils
    # dog
    dogdns

    whois

    # tls
    openssl
    gnutls
  ];

  terminal = [
    # urxvt
    rxvt_unicode

    # terminus font
    terminus_font
    terminus_font_ttf
  ];

  study = [
    # track documents
    zotero
    papis
  ];

  transform = [
    # streaming, filtering, and transforming data
    jq
    yq
    xmlstarlet
    zalgo
  ];

  nix = [
    # check hashes
    nix-prefetch-scripts

    # packaging
    python38Packages.python-slugify

    # format code
    nixfmt

    # build binaries
    patchelf

    # version management
    niv

    # caching
    cachix
  ];

  secrets = [
    # manage keys
    gnupg

    # managing passwords
    (pass.withExtensions(ext: with ext; [ pass-import pass-otp ]))

    # generating passwords
    pwgen
    diceware

    # 2FA
  ] ++ (pkgs.lib.optional (pkgs.stdenv.system != "x86_64-darwin") oathToolkit);

  ssh = [
    # advanced ssh
    assh

    # when authorized_keys won't work
    sshpass

    # tunneling
    sshuttle
  ];

  patches = [
    # bps + ips
    flips

    # other formats
    xdelta
  ];

  haskell = [
    # haskell setup
    haskellPackages.cabal-install
    ghc

    # keep stack around
    stack

    # best formatter :)
    ormolu
  ];

  google = [
    # still on gcloud
    google-cloud-sdk
  ];

  filesystem = [
    # checking space
    du-dust

    # managing files
    nnn
  ] ++ lib.optional (pkgs.stdenv.system != "x86_64-darwin") duf;

  chat = [
    # chat clients
    discord
    spectral
    kotatogram-desktop

    # twitch
    chatterino2
  ];

  virtualisation = [
    # qemu (no more virtualbox?)
    qemu
    qemu_kvm
  ];

  music = [
    # plays everything
    mpv

    # open source spotify client
    ncspot

    # music player daemon
    mpd
    mpdas
    ncmpcpp
  ];

  sound = [
    # pulse + alsa utilities
    pavucontrol
    pulsemixer
    alsaUtils
  ];

  mail = [
    # fetching
    isync

    # index + search
    notmuch
  ] ++ lib.optional (pkgs.stdenv.system == "x86_64-darwin") davmail;

  editor = [
    # emacs + tmux is powerful
    emacsGit

    # best of both worlds
    neovim
  ];

  search = [
    # rust rules
    fd
    sd
    ripgrep

    # fuzzy finding
    fzf
  ];

  torrents = [
    # cli client
    rtorrent
    qbittorrent-nox

    # straight from the source
    youtube-dl
    ytcc
  ];

  browser = [
    firefox
    chromium
    qutebrowser

    # bookmarks!
    pinboard

    # contextual browsing!
    surf

    # searching
    ddgr

    # chromium

    # native extensions
    brotab
    browserpass
  ];

  tmux = [
    # terminal multiplexer
    tmux

    # declarative session manager
    # tmuxp
  ];

  development = [
    # rust
    rustup
    rust-analyzer
    rusty-man

    # lua
    fennel

    # lisp
    racket
    sbcl

    # julia
    julia_17-bin

    # jacinda
    jacinda

    # prolog
    swiProlog

    # run things
    entr

    # count code
    tokei
    cloc

    # benchmark
    hyperfine
    rtss

    # colors
    pastel

    # debug
    hexyl
    gdb

    # nim
    nim

    # showing off
    silicon
    asciinema

    # databases
    sqlite
    sqldiff
    visidata
  ];

  hacking = [
    # reverse engineering
    radare2
    radare2-cutter
  ];

  archives = [
    # compression!
    unrar
    unzip
    p7zip
    zip
  ];

  dhall = [
    # typed programmable config
    dhall
    dhall-bash
    dhall-json
  ];

  git = with gitAndTools; [
    # nicer diffs
    diff-so-fancy
    delta

    # run commit checks, declaratively
    pre-commit

    # manage files outside of git
    git-annex
    git-annex-utils

    # git large files
    git-lfs

    # cli tools
    tig
    gitui

    # github
    gist
    gh

    # trimming
    git-trim
  ];

  doom = [
    # engines
    crispyDoom
    zdoom
    gzdoom
    prboom
    zandronum

    # finding wads
    doomseeker

    # level editing
    slade
  ];

  games = if (pkgs.stdenv.system == "x86_64-darwin") then
    [
      # tales of middle earth
      tome2
    ]
  else [
    # morrowind
    openmw

    # steam + lutris
    wine
    wine64
    (steam.override { extraPkgs = pkgs: with pkgs; [ pango harfbuzz libthai ]; })
    steam-run
    lutris

    # melee
    wiimms-iso-tools

    # emulation
    fceux
    retroarch

    # minecraft
    polymc

    # puzzles
    sgtpuzzles

    # quake
    quakespasm

    # runescape
    runelite

    # super smash bros melee
    slippi-netplay
    slippi-playback
    netplay2021
    appimage-p-plus
    p-plus

    # go
    qgo
  ];

  java = [
    # an open version
    openjdk11
  ];

  streaming = [
    # for recording
    vokoscreen

    # for twitch
    obs-studio
    screenkey
  ];

  xorg = [
    # wm managment
    wmctrl
    rofi
    arandr
    xdotool

    # style
    nitrogen
    compton
    xmobar

    # screenshots
    maim
    flameshot

    # clipboard
    xclip

    # screensaver
    xscreensaver
  ];

  voidheart = [
    # testing
    fetch-followers

    # graphic editing
    mtpaint
    krita
    grafx2

    # searching youtube
    ueberzug

    # twitter + mastodon
    python38Packages.rainbowstream
    toot

    # music managements
    beets

    # backups
    backblaze-b2

    # firmware flashing
    gcc-arm-embedded
    dfu-util

    # desktop
    xwinwrap
  ];

  hashicorp = [
    # neat tools
    terraform
    packer
    nomad
  ];

  work = [
    # ansible...
    ansible
    ansible-lint

    # jira!
    go-jira
  ];

  organization = [
    # timetracking
    wakatime

    # document archival
    wkhtmltopdf
  ];

  python = [
    # formatting
    black

    # dependencies
    poetry
  ];


  gameboy = [
    # assembly
    rgbds
  ];
}
