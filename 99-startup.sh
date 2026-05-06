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