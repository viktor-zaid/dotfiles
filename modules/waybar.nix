{ config, pkgs, lib, ... }:

let
  waybarJson = ''
  {
    "layer": "top",
    "position": "top",
    "height": 40,
    "width": 1920,
    "margin": "0 0 0 0",
    "spacing": 0,

    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["custom/network_traffic"],
    "modules-right": [
      "custom/updates",
      "backlight",
      "hyprland/language",
      "cpu",
      "memory",
      "battery",
      "pulseaudio",
      "network",
      "tray",
      "idle_inhibitor",
      "clock",
      "custom/power"
    ],

    "hyprland/workspaces": {
      "format": "{icon}",
      "on-click": "activate",
      "all-outputs": true,
      "sort-by-number": true,
      "format-icons": {
        "1": "1",
        "2": "2",
        "3": "3",
        "4": "4",
        "5": "5",
        "6": "6",
        "7": "7",
        "8": "8",
        "9": "9",
        "10": "10",
        "focused": "",
        "default": ""
      },
      "on-scroll-up": "hyprctl dispatch workspace e+1",
      "on-scroll-down": "hyprctl dispatch workspace e-1"
    },
    "hyprland/window": {
      "format": "{}",
      "icon": true,
      "icon-size": 20
    },
    "idle_inhibitor": {
      "format": "{icon}",
      "format-icons": {
        "activated": "",
        "deactivated": ""
      }
    },
    "tray": {
      "icon-size": 20,
      "spacing": 5
    },
    "clock": {
      "tooltip-format": "<big>{:%A, %d.%B %Y }</big>\\n<tt><small>{calendar}</small></tt>",
      "format": " {:%d/%m/%Y  %I:%M:%S %p}",
      "interval": 1,
      "on-click": "~/.config/waybar/scripts/OCV"
    },
    "cpu": {
      "format": "🖳{usage}%"
    },
    "memory": {
      "format": " {: >3}%"
    },
    "backlight": {
      "format": "{icon} {percent: >3}%",
      "format-icons": ["", ""],
      "on-scroll-down": "brightnessctl -c backlight set 1%-",
      "on-scroll-up": "brightnessctl -c backlight set +1%"
    },
    "battery": {
      "states": {
        "warning": 30,
        "critical": 15
      },
      "format": "{icon} {capacity: >3}%",
      "format-icons": ["", "", "", "", ""],
      "format-charging": "{capacity}% ",
      "format-plugged": "{capacity}% ",
      "format-full": "FULL 󱟢"
    },
    "network": {
      "format": "⚠Disabled",
      "format-wifi": "",
      "format-ethernet": "",
      "format-linked": "{ifname} (No IP)",
      "format-disconnected": "⚠Disabled",
      "format-alt": "{ifname}: {ipaddr}/{cidr}",
      "family": "ipv4",
      "tooltip-format-wifi": "  {ifname} @ {essid}\\nIP: {ipaddr}\\nStrength: {signalStrength}%\\nFreq: {frequency}MHz\\nUp: {bandwidthUpBits} Down: {bandwidthDownBits}",
      "tooltip-format-ethernet": " {ifname}\\nIP: {ipaddr}\\n up: {bandwidthUpBits} down: {bandwidthDownBits}"
    },
    "custom/updates": {
      "format": "{} {icon}",
      "return-type": "json",
      "format-icons": {
        "has-updates": "󱍷",
        "updated": "󰂪"
      },
      "interval": 7200,
      "exec-if": "which waybar-module-pacman-updates",
      "exec": "waybar-module-pacman-updates",
      "on-click": "foot -e update"
    },
    "custom/power": {
      "format": "⏻",
      "on-click": "nwgbar",
      "tooltip": false
    },
    "hyprland/language": {
      "format": " {shortDescription}"
    },
    "custom/launcher": {
      "format": "    ",
      "on-click": "exec nwg-drawer -c 7 -is 70 -spacing 23",
      "tooltip": false
    },
    "custom/network_traffic": {
      "exec": "~/.config/waybar/scripts/network_traffic.sh",
      "return-type": "json",
      "format-ethernet": "{icon} {ifname} ⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}"
    },
    "pulseaudio": {
      "scroll-step": 3,
      "format": "{icon} {volume}% {format_source}",
      "format-bluetooth": "{volume}% {icon} {format_source}",
      "format-bluetooth-muted": " {icon} {format_source}",
      "format-muted": " {format_source}",
      "format-source": "",
      "format-source-muted": "",
      "format-icons": {
        "headphone": "",
        "hands-free": "",
        "headset": "",
        "phone": "",
        "portable": "",
        "car": "",
        "default": ["", "", ""]
      },
      "on-click": "pavucontrol",
      "on-click-right": "pactl set-source-mute @DEFAULT_SOURCE@ toggle"
    },
    "custom/weather": {
      "exec": "curl 'https://wttr.in/Essen?format=2'",
      "interval": 900,
      "on-click": "yad --html --uri='https://wttr.in/Essen' --center --fixed --width=1000 --height=680 --timeout=60 --timeout-indicator=right"
    }
  }
  '';

  waybarCss = ''
  /* =============================================================================
   *
   * Waybar configuration
   *
   * Configuration reference: https://github.com/Alexays/Waybar/wiki/Configuration
   *
   * =========================================================================== */

  /* -----------------------------------------------------------------------------
   * Keyframes
   * -------------------------------------------------------------------------- */

  /*
  Polar Night
  nord0  #2e3440
  nord1  #3b4252
  nord2  #434c5e
  nord3  #4c566a
  Snow Storm
  nord4  #d8dee9
  nord5  #e5e9f0
  nord6  #eceff4
  Frost
  nord7  #8fbcbb
  nord8  #88c0d0
  nord9  #81a1c1
  nord10 #5e81ac
  Aurora
  nord11 #bf616a
  nord12 #d08770
  nord13 #ebcb8b
  nord14 #a3be8c
  nord15 #b48ead
  */

  /* -----------------------------------------------------------------------------
   * Base styles
   * -------------------------------------------------------------------------- */

  /* Reset all styles */

  * {
      border: 0;
      border-radius: 0;
      padding: 0 0;
      font-family: Symbols Nerd Font Mono;
      font-size: 15px;
      margin-right: 5px;
      margin-left: 5px;
      padding-bottom: 2px;
  }

  tooltip {
      background-color: rgba(43, 48, 59, 0.95);
      border: 1px solid rgba(100, 114, 125, 0.5);
  }
  tooltip label {
      color: #eceff4;
  }
  window#waybar {
      background: rgba(0, 0, 0, 0.5);
      /* border-radius: 20px 20px 20px 20px; */
  }

  #workspaces button {
      padding: 2px 0px;
      border-bottom: 2px;
      color: #eceff4;
      border-color: #d8dee9;
      border-style: solid;
      margin-top: 2px;
  }

  #workspaces button.active {
      border-color: #81a1c1;
  }

  #workspaces button:hover {
      background: rgba(0, 0, 0, 0.2);
      color: #88c0d0;
      border-color: #88c0d0;
      box-shadow: inherit;
      text-shadow: inherit;
  }

  #workspaces button.active:hover {
      background: rgba(0, 0, 0, 0.2);
      color: #81a1c1;
      border-color: #81a1c1;
  }

  #clock, #battery, #cpu, #memory, #idle_inhibitor, #temperature, #custom-keyboard-layout,
  #backlight, #pulseaudio, #tray, #window, #custom-launcher, #custom-power, #custom-updates {
      color: #ffffff;
      padding: 0 3px;
      border-bottom: 2px;
      border-style: solid;
  }

  /* -----------------------------------------------------------------------------
   * Module styles
   * -------------------------------------------------------------------------- */

  #clock {
      color: #a3be8c;
  }

  #backlight {
      color: #ebcb8b;
  }

  #battery {
      color: #d8dee9;
  }

  #battery.charging {
      color: #81a1c1;
  }

  #language {
      color: #d08770;
  }

  @keyframes blink {
      to {
          color: #4c566a;
          background-color: #eceff4;
      }
  }

  #battery.critical:not(.charging) {
      background: #bf616a;
      color: #eceff4;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
  }

  #cpu {
      color: #a3be8c;
  }

  #memory {
      color: #d3869b;
  }

  #network.disabled {
      color: #bf616a;
  }

  #network {
      color: #a3be8c;
  }

  #network.disconnected {
      color: #bf616a;
  }

  #pulseaudio {
      color: #b48ead;
  }

  #pulseaudio.muted {
      color: #3b4252;
  }

  #temperature {
      color: #8fbcbb;
  }

  #temperature.critical {
      color: #bf616a;
  }

  #idle_inhibitor {
      color: #ebcb8b;
  }

  #tray {
  }

  #custom-launcher {
      font-size: 20px;
      background-image: url('/home/zaid/.config/waybar/launcher.png');
      background-position: center;
      background-repeat: no-repeat;
      background-size: contain;
      border-style: hidden;
  }

  #custom-power {
      border-style: hidden;
      margin-top: 2px;
  }

  #window {
      border-style: hidden;
      margin-top: 1px;
  }

  #custom-keyboard-layout {
      color: #d08770;
  }

  #custom-network_traffic {
      color: #d08770;
  }
  '';
in
{
  programs.waybar = {
    enable = true;
    enableTray = true; # Enable system tray
    package = pkgs.waybar;

    # The main JSON config
    config = waybarJson;

    # The style (CSS)
    css = waybarCss;

    # Optionally, specify additional scripts or files
    # You can manage your scripts using home.file or similar options
  };
}


