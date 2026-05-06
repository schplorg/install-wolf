#!/bin/bash

# Force all new windows into fullscreen
echo 'for_window [app_id=".*"] fullscreen enable' >> ~/.config/sway/custom-cfg
echo 'for_window [class=".*"] fullscreen enable' >> ~/.config/sway/custom-cfg

# --- Fullscreen ---
echo 'bindsym $mod+f fullscreen toggle' >> ~/.config/sway/custom-cfg
echo 'bindsym $mod+shift+f fullscreen toggle global' >> ~/.config/sway/custom-cfg

# --- Window switching ---
echo 'bindsym $mod+Tab focus next' >> ~/.config/sway/custom-cfg
echo 'bindsym $mod+shift+Tab focus prev' >> ~/.config/sway/custom-cfg
echo 'bindsym alt+Tab focus next' >> ~/.config/sway/custom-cfg
echo 'bindsym alt+shift+Tab focus prev' >> ~/.config/sway/custom-cfg

# --- Access menubar/toolbar (exit fullscreen temporarily) ---
echo 'bindsym $mod+m fullscreen disable' >> ~/.config/sway/custom-cfg