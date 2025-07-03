{ config, pkgs, lib, ... }:

{
  # Install Sublime Text 4
  home.packages = with pkgs; [
    sublime4
  ];

  # Create directories for Sublime Text configuration
  home.file = {
    # Writer Color Scheme
    ".config/sublime-text/Packages/User/Writer.sublime-color-scheme" = {
      text = ''
        {
          "name": "Writer",
          "author": "Nikita Tonsky",
          "variables": {
            "background": "#fafafa",
            "foreground": "#424242",
            "caret": "#424242",
            "selection": "#d7d7d7",
            "selection_border": "#d7d7d7",
            "line_highlight": "#f5f5f5"
          },
          "globals": {
            "background": "var(background)",
            "foreground": "var(foreground)",
            "caret": "var(caret)",
            "selection": "var(selection)",
            "selection_border": "var(selection_border)",
            "line_highlight": "var(line_highlight)",
            "brackets_options": "none",
            "brackets_foreground": "var(foreground)",
            "bracket_contents_options": "none",
            "bracket_contents_foreground": "var(foreground)"
          },
          "rules": [
            {
              "scope": "markup.heading",
              "font_style": "bold"
            },
            {
              "scope": "markup.italic",
              "font_style": "italic"
            },
            {
              "scope": "markup.bold",
              "font_style": "bold"
            },
            {
              "scope": "markup.raw",
              "background": "#f0f0f0"
            }
          ]
        }
      '';
    };

    # Writer Color Scheme Dark
    ".config/sublime-text/Packages/User/Writer Dark.sublime-color-scheme" = {
      text = ''
        {
          "name": "Writer Dark",
          "author": "Nikita Tonsky",
          "variables": {
            "background": "#1e1e1e",
            "foreground": "#d4d4d4",
            "caret": "#d4d4d4",
            "selection": "#3a3a3a",
            "selection_border": "#3a3a3a",
            "line_highlight": "#2a2a2a"
          },
          "globals": {
            "background": "var(background)",
            "foreground": "var(foreground)",
            "caret": "var(caret)",
            "selection": "var(selection)",
            "selection_border": "var(selection_border)",
            "line_highlight": "var(line_highlight)",
            "brackets_options": "none",
            "brackets_foreground": "var(foreground)",
            "bracket_contents_options": "none",
            "bracket_contents_foreground": "var(foreground)"
          },
          "rules": [
            {
              "scope": "markup.heading",
              "font_style": "bold"
            },
            {
              "scope": "markup.italic",
              "font_style": "italic"
            },
            {
              "scope": "markup.bold",
              "font_style": "bold"
            },
            {
              "scope": "markup.raw",
              "background": "#2a2a2a"
            }
          ]
        }
      '';
    };

    # Writing Profile Settings
    ".config/sublime-text/Packages/User/Profiles/Writing.sublime-settings" = {
      text = ''
        {
          "caret_extra_width": 2,
          "draw_centered": true,
          "draw_indent_guides": false,
          "draw_white_space": ["none"],
          "font_face": "IBM Plex Mono",
          "font_size": 16,
          "gutter": false,
          "highlight_line": false,
          "line_padding_bottom": 3,
          "line_padding_top": 3,
          "margin": 10,
          "scroll_context_lines": 2,
          "scroll_past_end": 0.5,
          "word_wrap": true,
          "wrap_width": 72,
          "color_scheme": "Packages/User/Writer.sublime-color-scheme",
          "theme": "Adaptive.sublime-theme"
        }
      '';
    };

    # Profile Switcher Package Settings
    ".config/sublime-text/Packages/User/ProfileSwitcher.sublime-settings" = {
      text = ''
        {
          "profiles": {
            "Default": "Preferences.sublime-settings",
            "Writing": "Profiles/Writing.sublime-settings"
          }
        }
      '';
    };

    # Package Control Settings to auto-install packages
    ".config/sublime-text/Packages/User/Package Control.sublime-settings" = {
      text = ''
        {
          "bootstrapped": true,
          "in_process_packages": [],
          "installed_packages": [
            "Package Control",
            "Profile Switcher"
          ],
          "repositories": [
            "https://github.com/tonsky/sublime-profiles"
          ]
        }
      '';
    };

    # Default Sublime Text settings
    ".config/sublime-text/Packages/User/Preferences.sublime-settings" = {
      text = ''
        {
          "font_face": "JetBrains Mono",
          "font_size": 14,
          "theme": "Adaptive.sublime-theme",
          "color_scheme": "Packages/Color Scheme - Default/Monokai.sublime-color-scheme",
          "translate_tabs_to_spaces": true,
          "tab_size": 2,
          "rulers": [80, 120],
          "word_wrap": false,
          "show_line_numbers": true,
          "highlight_line": true,
          "caret_style": "phase",
          "wide_caret": true,
          "caret_extra_width": 1,
          "scroll_past_end": true,
          "fold_buttons": true,
          "fade_fold_buttons": true,
          "show_full_path": true,
          "overlay_scroll_bars": "enabled",
          "always_show_minimap_viewport": true,
          "draw_minimap_border": true,
          "bold_folder_labels": true,
          "indent_guide_options": ["draw_normal", "draw_active"],
          "draw_white_space": "selection",
          "trim_trailing_white_space_on_save": true,
          "ensure_newline_at_eof_on_save": true,
          "save_on_focus_lost": true,
          "hot_exit": false,
          "remember_open_files": false
        }
      '';
    };
  };

  # Install IBM Plex Mono font (closest to the author's custom font)
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    ibm-plex
  ];

  # Create a shell script to easily switch to writing mode
  home.file.".local/bin/sublime-writer" = {
    text = ''
      #!/bin/sh
      # Launch Sublime Text in writing mode
      sublime_text --command "profiles_switch_profile Writing"
    '';
    executable = true;
  };
}

