#!/bin/bash

echo 'for_window [app_id=".*"] fullscreen enable' >> ~/.config/sway/custom-cfg
echo 'for_window [class=".*"] fullscreen enable' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+f fullscreen toggle' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+shift+f fullscreen toggle global' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+Tab focus next' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+shift+Tab focus prev' >> ~/.config/sway/custom-cfg
echo 'bindsym alt+Tab focus next' >> ~/.config/sway/custom-cfg
echo 'bindsym alt+shift+Tab focus prev' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+m fullscreen disable' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+1 workspace number 1' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+2 workspace number 2' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+3 workspace number 3' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+4 workspace number 4' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+5 workspace number 5' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+left workspace prev' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+right workspace next' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+shift+1 move container to workspace number 1' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+shift+2 move container to workspace number 2' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+shift+3 move container to workspace number 3' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+shift+4 move container to workspace number 4' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+shift+5 move container to workspace number 5' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+d exec wofi --show drun' >> ~/.config/sway/custom-cfg
echo 'bindsym Mod4+return exec foot' >> ~/.config/sway/custom-cfg

echo 'bindsym Mod4+q kill' >> ~/.config/sway/custom-cfg