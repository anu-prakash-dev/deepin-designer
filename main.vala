/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2011 ~ 2016 Deepin, Inc.
 *               2011 ~ 2016 Wang Yong
 *
 * Author:     Wang Yong <wangyong@deepin.com>
 * Maintainer: Wang Yong <wangyong@deepin.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 

using Gdk;
using Gee;
using Gtk;
using Keymap;
using Widgets;

const string GETTEXT_PACKAGE = "deepin-designer"; 

public class Application : Object {
    private bool inited = false;

    public static void main(string[] args) {
        // NOTE: set IBUS_NO_SNOOPER_APPS variable to avoid Ctrl + 5 eat by input method (such as fcitx.);
        Environment.set_variable("IBUS_DISABLE_SNOOPER", "1", true);
        
        Intl.setlocale();
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8");
        Intl.bindtextdomain(GETTEXT_PACKAGE, "/usr/share/locale");
        
        Gtk.init(ref args);
        Application app = new Application();
        app.run();
        Gtk.main();
    }

    public void run() {
        // Bus.own_name is callback, when application exit will execute `run` function.
        // Use inited variable to avoid application run by Bus.own_name release.
        if (inited) {
            return;
        }
        inited = true;
        
        Utils.load_css_theme(Utils.get_root_path("style.css"));
        var win = new Widgets.Window();
        win.show_window();
    }
}
