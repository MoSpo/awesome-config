-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
--local cairo = require("lgi").cairo
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
fileexplorer = "dolphin"
editor = "vim" or os.getenv("EDITOR")
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   -- awful.layout.suit.floating,
    awful.layout.suit.tile,
   -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral,
   -- awful.layout.suit.spiral.dwindle,
   -- awful.layout.suit.max,
   -- awful.layout.suit.max.fullscreen,
   -- awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                    c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    --set_wallpaper(s)

    -- Each screen has its own tag table.
    --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    for i=0, 5 do
	awful.tag.add(string.upper(string.format("%x", i+10)),{ 
	layout             = awful.layout.suit.tile,
        master_fill_policy = "master_width_factor",
        gap_single_client  = true,
	gap                = 15,
        screen             = s,
	selected           = (i==0),
        })
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    
    beautiful.wibar_opacity = 0;
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    --s.mywibox:setup {
    --    layout = wibox.layout.align.horizontal,
    --    { -- Left widgets
    --        layout = wibox.layout.fixed.horizontal,
    --        mylauncher,
    --        s.mytaglist,
    --        s.mypromptbox,
    --    },
    --    s.mytasklist, -- Middle widget
    --    { -- Right widgets
    --        layout = wibox.layout.fixed.horizontal,
    --        mykeyboardlayout,
    --        wibox.widget.systray(),
    --       mytextclock,
    --        s.mylayoutbox,
    --    },
    --}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

    local rotr = [[bash -c '
rotation=`xrandr -q --verbose|grep eDP-1|cut -b46`
case "$rotation" in
   "n") xrandr -o right 
   ;;
   "l") xrandr -o normal
   ;;
   "i") xrandr -o left
   ;;
   "r") xrandr -o inverted
   ;;
esac
']]

local rotl = [[bash -c '
rotation=`xrandr -q --verbose|grep eDP-1|cut -b46`
case "$rotation" in
   "n") xrandr -o left 
   ;;
   "l") xrandr -o inverted
   ;;
   "i") xrandr -o right
   ;;
   "r") xrandr -o normal
   ;;
esac
']]

local floatingLayout = {false, false, false, false, false, false};


-- {{{ Key bindings
globalkeys = gears.table.join(
        awful.key({ modkey, "Shift"   }, "Left",   function()
        local c = client.focus
        if client.focus then
            local tag = client.focus.screen.tags[1 + ((client.focus.screen.selected_tag.index - 2) % 6)]
                if tag then
                    if floatingLayout[tag.index] then
                        if not c.floating then
                            local oy = c.y
                            c.height = c.height - 26
                            awful.titlebar.show(c)
                            c.y = oy
                        end
                    else
                        if not c.floating then
                            awful.titlebar.hide(c)
                        end
                    end
                client.focus:move_to_tag(tag)
            end
        end
        awful.tag.viewprev()
    end,
              {description = "move previous", group = "tag"}),
    awful.key({ modkey, "Shift"    }, "Right",  function() 
        local c = client.focus
        if client.focus then
            local tag = client.focus.screen.tags[1 + ((client.focus.screen.selected_tag.index) % 6)]
                if tag then
                    if floatingLayout[tag.index] then
                        if not c.floating then
                            local oy = c.y
                            c.height = c.height - 26
                            awful.titlebar.show(c)
                            c.y = oy
                        end
                    else
                        if not c.floating then
                            awful.titlebar.hide(c)
                        end
                    end
                client.focus:move_to_tag(tag)
            end
        end
        awful.tag.viewnext()
    end,
              {description = "move next", group = "tag"}),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "g", function ()
        local scr = awful.screen.focused()
        if scr.selected_tag.gap > 0 then
            scr.selected_tag.gap = 0
        else 
            scr.selected_tag.gap = 15
        end
        awful.layout.arrange(scr)
    end,
    {description = "toggle gaps", group = "awesome"}),
    

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    --awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    --          {description = "focus the next screen", group = "screen"}),
    --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    --          {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    
    awful.key({ modkey,           }, "#", function () awful.spawn(fileexplorer) end,
              {description = "open a file explorer", group = "launcher"}),
    --awful.key({ modkey, "Control" }, "r", awesome.restart,
    --          {description = "reload awesome", group = "awesome"}),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit,
    --          {description = "quit awesome", group = "awesome"}),
              

    awful.key({ modkey, "Control" }, "q",     function () awful.spawn.easy_async(rotl,         function(stdout, stderr, reason, exit_code)
        end)
    end,
              {description = "rotate screen left", group = "awesome"}), 	
              
    awful.key({ modkey, "Control" }, "e",      function () awful.spawn.easy_async(rotr,  function(stdout, stderr, reason, exit_code)
        end)
    end,
              {description = "rotate screen right", group = "awesome"}), 

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1 , nil , awful.layout.layouts)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function ()
        local t = awful.screen.focused().selected_tag
        floatingLayout[t.index] = not floatingLayout[t.index]
        for _,c in pairs( t:clients()) do
            if  not(c.class == "plasmashell" or c.class == "krunner") and not(c.fullscreen) then
                if floatingLayout[t.index] then
                if not c.floating then
                    local oy = c.y
                    c.height = c.height - 26
                    awful.titlebar.show(c)
                    c.y = oy
                end
                else
                if not c.floating then
                    awful.titlebar.hide(c)
                end
                end
            end
        end
        if floatingLayout[t.index] then
            awful.layout.set(awful.layout.suit.floating)
        else
            awful.layout.set(awful.layout.layouts[1]) 
        end
    end,
              {description = "set floating", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            if c.class ~= "plasmashell" then
                if c.fullscreen then
                    c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,15) end
                    awful.client.shape.update.all(c)
                    c.fullscreen = false
                else
                    c.shape = function(cr,w,h) gears.shape.rectangle(cr,w,h) end
                    awful.client.shape.update.all(c)
                    c.fullscreen = true
                end
                c:raise()
            end
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",     
        function(c)
            if  c.class ~= 'plasmashell' then
                c:kill()
            end
        end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space", 
        function(c)
            if  not(c.class == "plasmashell" or c.class == "krunner") and not(c.fullscreen) then
                c.floating = not c.floating
            end
        end,
              {description = "toggle floating", group = "client"}),
              
              
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    --awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
    --          {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "t",      function (c) 
        if not (c.class == "plasmashell" or c.class == "krunner") then
            if c.ontop then
                c.ontop = false
                c.border_color = beautiful.border_focus
            else
                c.ontop = true
                c.border_color = "#EC3636"
            end
        end
    end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) 
        if not (c.class == "plasmashell" or c.class == "krunner") then
            if c.sticky then
                c.sticky = false
                c.border_color = beautiful.border_focus
            else
                c.sticky = true
                c.border_color = "#F67400"
            end
        end
    end,
              {description = "toggle sticky", group = "client"}),    
              
    awful.key({ modkey,           }, "n",
        function (c)
            if c.class ~= "plasmashell" then
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            local f = c.floating
            if c.class ~= "plasmashell" then
                if c.fullscreen then c.fullscreen = false end
                c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,15) end
                c.maximized_vertical = false
                c.maximized_horizontal = false
                c.maximized = not c.maximized
                c.floating = f
                c:raise()
            end
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            local f = c.floating
            if c.class ~= "plasmashell" then
                if c.fullscreen then c.fullscreen = false end
                c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,15) end
                c.maximized = false
                c.maximized_horizontal = false
                c.maximized_vertical = not c.maximized_vertical
                c.floating = f
                c:raise()
            end
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            local f = c.floating
            if c.class ~= "plasmashell" then
                if c.fullscreen then c.fullscreen = false end
                c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,15) end
                c.maximized_vertical = false
                c.maximized_horizontal = false
                c.maximized_horizontal = not c.maximized_horizontal
                c.floating = f
                c:raise()
            end
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) 
        if not(c.class == "plasmashell") then
            client.focus = c;
            c:raise()
        end
    end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     maximized = false;
                     maximized_vertical = false,
                     maximized_horizontal = false,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
    {
    rule = { class = "plasmashell" },
    properties = { floating = true },
    callback = function(c)
       if c.type == "desktop" then
            c.fullscreen = true
       end
    end,
    },
    {
    rule = { class = "krunner" },
    properties = { floating = true },
    callback = function(c)
    end,
    },
    {
    rule = { class = "ksmserver" },
    properties = { maximized = true }
    },
    {
    rule = { class = "Chromium" },
        properties = { 
            floating = false;
            maximized = false;
            maximized_vertical = false,
            maximized_horizontal = false,
        },
        callback = function(c)
            c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
        end,
    },
    {
    rule = { class = "Firefox" },
    properties = { 
        floating = false;
        maximized = false;
        maximized_vertical = false,
        maximized_horizontal = false,
    },
    callback = function(c)
    c.maximized, c.maximized_vertical, c.maximized_horizontal = false, false, false
        end,
    },
    
    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          --"pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
    if (not awesome.startup) and c.class == "plasmashell" then 
	 awful.placement.under_mouse(c)
	awful.placement.no_offscreen(c)
    end
    if (not awesome.startup) and c.class == "krunner" then
	awful.placement.top(c)
	awful.placement.no_offscreen(c)
    end
    if not(c.type == "dock" or c.type == "desktop" or c.class == "ksmserver") then 
        c.shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,15) end
    end
    c.ignore_border_width = false
    c.border_width = 2
    local t = timer({ timeout = 600 })
    t:connect_signal("timeout", function()
        collectgarbage("collect")
    end)
    t:start()
    t:emit_signal("timeout")
end)

client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            --awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            --awful.titlebar.widget.floatingbutton (c),
            --awful.titlebar.widget.maximizedbutton(c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.ontopbutton    (c),
            --awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
    if (c.floating and not(c.class == "plasmashell" or c.class == "krunner")) or floatingLayout[awful.screen.focused().selected_tag.index]  then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
    
end)

client.connect_signal("property::floating", function (c)
    if not(c.class == "plasmashell" or c.class == "krunner") then
    if c.floating then
        local oy = c.y
        c.height = c.height - 26
        awful.titlebar.show(c)
        c.y = oy
    else
        if c.maximized or c.maximized_horizontal or c.maximized_vertical then
        c.y = c.y - 26
        c.height = c.height + 26
        end
        awful.titlebar.hide(c)
    end
    else
        c.y = c.y - 26
        awful.titlebar.hide(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("button::press", function(c)
        local mx = mouse.coords().x
        local my = mouse.coords().y
        local g = c:geometry()

        if my > g.y + 30 and ((mx > g.x and mx < g.x + 10) or
            (mx > g.x + g.width -10 and mx < g.x + g.width) or
            (my > g.y and my < g.y + 10) or
            (my > g.y + g.height -10 and my < g.y + g.height)) then
                awful.mouse.client.resize(c)
        end                                    
end)

client.connect_signal("focus", function(c)
    if mouse.object_under_pointer() ~= c and not (c.class == "plasmashell" and c.type ~= "menu")then
        if c.class == "plasmashell" and c.type == "menu" then
            local geometry = c:geometry()
            local x = geometry.x + geometry.width/2
            local y = geometry.y + geometry.height/2
            mouse.coords({x = x}, true)
       else
            local geometry = c:geometry()
            local x = geometry.x + geometry.width/2
            local y = geometry.y + geometry.height/2
            mouse.coords({x = x, y = y}, true)
        end
    end
    
    if c.sticky and (not (c.class == "plasmashell" or c.class == "krunner")) then
        c.border_color = "#F67400"
    elseif c.ontop and (not (c.class == "plasmashell" or c.class == "krunner")) then
        c.border_color = "#EC3636"
    elseif c.type ~= "dock" and c.type ~= "desktop" then
        c.border_color = beautiful.border_focus
    end
                                          
end)

client.connect_signal("unfocus", function(c) 
    if (c.sticky or c.ontop) and (not (c.class == "plasmashell" or c.class == "krunner")) then
        c.border_color = "#5E3636"
    else
        c.border_color = beautiful.border_normal
    end
end)
-- }}}
