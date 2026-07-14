{ config, pkgs, lib, ... }:

{
  home.username = "xgoffin";
  home.homeDirectory = "/home/xgoffin";
  home.stateVersion= "25.05";

  home.packages = with pkgs; [
    wget
    curl
    git
    jq
    ibus
    mozc
    zip
    xz
    unzip
    dnsutils
    cowsay
    which
    tree
    gnupg
    go
    rbenv
    nodejs
    postgresql
    cassandra
    docker
    firefox
    slack
    discord
    kubectl
    golangci-lint
    go-tools
    fortune
    opencode
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.just-perfection
    gnomeExtensions.no-overview
    gnomeExtensions.pop-shell
    gnomeExtensions.resource-monitor
    gnomeExtensions.just-shows-memory-usage
  ];

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
	(lib.hm.gvariant.mkTuple [ "xkb" "fr+azerty" ])
	(lib.hm.gvariant.mkTuple [ "xkb" "us+intl" ])
      ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Super>space" ];
    };
    "org/gnome/desktop/session" = {
      idle-delay = "uint32 0";
    };
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/mutter" = {
      overlay-key = "Super_L";
    };
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "just-perfection-desktop@just-perfection"
        "just-shows-memory-usage@troizet.github.com"
        "no-overview@fthx"
        "Resource_Monitor@Ory0n"
      ];
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "Pop-dark";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme=false;
      background-opacity=0.80000000000000004;
      click-action="minimize-or-previews";
      dash-max-icon-size=64;
      dock-fixed=false;
      dock-position="BOTTOM";
      extend-height=false;
      height-fraction=0.90000000000000002;
      intellihide=false;
      manualhide=false;
      multi-monitor=true;
      preferred-monitor=-2;
      preferred-monitor-by-connector="eDP-1";
      show-trash=false;
    };
     
    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu=false;
      activities-button=true;
      quick-settings=true;
      quick-settings-airplane-mode=true;
      quick-settings-dark-mode=true;
      support-notifier-showed-version=36;
    };
     
    "org/gnome/shell/extensions/resource-monitor" = {
      cpufrequencystatus=true;
      diskspacestatus=false;
      diskstatsstatus=false;
      displaymode="primary";
      extensionposition="right";
      iconsposition="left";
      leftclickstatus="custom-program";
      netethstatus=false;
      netwlanstatus=false;
      rammonitor="used";
      ramstatus=false;
      ramunit="numeric";
      refreshtime=10;
      thermalcputemperaturestatus=true;
      thermalcputemperaturewidth=0;
    };
  };

  programs.bash = {
    enable = true;

    historySize = -1;
    historyFileSize = -1;
    historyControl = [ "ignoreboth" ];

    shellAliases = {
      ":q" = "exit";
    };

    bashrcExtra = ''
    # Load secrets
    if [ -f ~/.bashrc.secrets ]; then
      source ~/.bashrc.secrets
    fi
    '';
  };
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-go coc-nvim ];
    settings = { ignorecase = true; };
    extraConfig = ''
      " Sets how many lines of history VIM has to remember
      set history=500
       
      " Enable filetype plugins
      filetype plugin on
      filetype indent on
       
      " Set to auto read when a file is changed from the outside
      set autoread
      au FocusGained,BufEnter * checktime
       
      " :W sudo saves the file
      " (useful for handling the permission-denied error)
      command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
       
       
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => VIM user interface
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Set 7 lines to the cursor - when moving vertically using j/k
      set so=7
       
      " Avoid garbled characters in Chinese language windows OS
      let $LANG='en'
      set langmenu=en
       
      " Ignore compiled files
      set wildignore=*.o,*~,*.pyc
      if has("win16") || has("win32")
          set wildignore+=.git\*,.hg\*,.svn\*
      else
          set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
      endif
       
      " Always show current position
      set ruler
       
      " Height of the command bar
      set cmdheight=1
       
      " A buffer becomes hidden when it is abandoned
      set hid
       
      " Configure backspace so it acts as it should act
      set backspace=eol,start,indent
      set whichwrap+=<,>,h,l
       
      " Ignore case when searching
      set ignorecase
       
      " When searching try to be smart about cases
      set smartcase
       
      " Highlight search results
      set hlsearch
       
      " Makes search act like search in modern browsers
      set incsearch
       
      " Don't redraw while executing macros (good performance config)
      set lazyredraw
       
      " For regular expressions turn magic on
      set magic
       
      " Show matching brackets when text indicator is over them
      set showmatch
       
      " No annoying sound on errors
      set noerrorbells
      set novisualbell
      set t_vb=
      set tm=500
       
      " Properly disable sound on errors on MacVim
      if has("gui_macvim")
          autocmd GUIEnter * set vb t_vb=
      endif
       
      set number
       
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Colors and Fonts
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Enable syntax highlighting
      syntax enable
       
      " Set regular expression engine automatically
      set regexpengine=0
       
      " Enable 256 colors palette in Gnome Terminal
      if $COLORTERM == 'gnome-terminal'
          set t_Co=256
      endif
       
      " Set extra options when running in GUI mode
      if has("gui_running")
          set guioptions-=T
          set guioptions-=e
          set t_Co=256
          set guitablabel=%M\ %t
      endif
       
      " Set utf8 as standard encoding and en_US as the standard language
      set encoding=utf8
       
      " Use Unix as the standard file type
      set ffs=unix,dos,mac
       
      set termguicolors
       
      " have cursor on the right when splitting
      set splitright
       
      colorscheme desert
       
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Text, tab and indent related
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Use spaces instead of tabs
      set expandtab
       
      " Be smart when using tabs ;)
      set smarttab
       
      " 1 tab == 4 spaces
      set shiftwidth=4
      set tabstop=4
       
      " Linebreak on 500 characters
      set lbr
      set tw=500
       
      set ai "Auto indent
      set si "Smart indent
      set wrap "Wrap lines
       
      " Prevent wanton deletes by ctrl-u
      inoremap <c-u> <c-g>u<c-u>
       
      " Disable parentheses matching depends on system. This way we should address all cases (?)
      set noshowmatch
      " NoMatchParen  This doesnt work as it belongs to a plugin, which is only loaded _after_ all files are.
      " Trying disable MatchParen after loading all plugins
      "
      function! g:FckThatMatchParen ()
          if exists(":NoMatchParen")
              :NoMatchParen
          endif
      endfunction
       
      augroup plugin_initialize
          autocmd!
          autocmd VimEnter * call FckThatMatchParen()
      augroup END
       
      set t_u7=
      let g:go_diagnostics_level = 2
      let g:go_def_mode='gopls'
      let g:go_info_mode='gopls'
       
      set mouse=a
       
      command! W write
      set tw=0
    '';
  };

  xdg.configFile."autostart/slack.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Slack
    Exec=${pkgs.slack}/bin/slack
    X-GNOME-Autostart-enabled=true
  '';

  xdg.configFile."autostart/discord.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Discord
    Exec=${pkgs.discord}/bin/discord
    X-GNOME-Autostart-enabled=true
  '';

  xdg.configFile."autostart/terminal.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Terminal
    Exec=gnome-terminal
    X-GNOME-Autostart-enabled=true
  '';

  xdg.configFile."autostart/gnome-clocks.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Clocks
    Exec=gnome-clocks
    X-GNOME-Autostart-enabled=true
  '';
}
