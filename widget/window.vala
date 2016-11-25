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

using Cairo;
using Config;
using Gtk;
using XUtils;
using Widgets;

namespace Widgets {
    public class Window : Gtk.Window {
        public Gdk.RGBA top_line_dark_color;
        public Gdk.RGBA top_line_light_color;
        public Gtk.Box spacing_box;
        public bool draw_tabbar_line = true;
        public double window_default_scale = 0.7;
        public int window_frame_margin_bottom = 60;
        public int window_frame_margin_end = 50;
        public int window_frame_margin_start = 50;
        public int window_frame_margin_top = 50;
        public int window_fullscreen_monitor_height = Constant.TITLEBAR_HEIGHT * 2;
        public int window_fullscreen_monitor_timeout = 150;
        public int window_fullscreen_response_height = 5;
        public int window_height;
        public int window_widget_margin_bottom = 2;
        public int window_widget_margin_end = 2;
        public int window_widget_margin_start = 2;
        public int window_widget_margin_top = 1;
        public int window_width;
        public Widgets.ToolbarBox toolbar_box;
        public Widgets.Workspace workspace;
        
        private bool is_show_shortcut_viewer = false;
        public Config.Config config;
        public Gdk.RGBA title_line_dark_color;
        public Gdk.RGBA title_line_light_color;
        public Gtk.Box window_frame_box;
        public Gtk.Box window_widget_box;
        public bool config_theme_is_light=true;
        public int cache_height = 0;
        public int cache_width = 0;
        public int reset_timeout_delay = 150;
        public int resize_timeout_delay = 150;
        public int resize_cache_x = 0;
        public int resize_cache_y = 0;
        public uint? reset_timeout_source_id = null;
        public uint? resize_timeout_source_id = null;
            
        public Window() {
            Intl.bindtextdomain(GETTEXT_PACKAGE, "/usr/share/locale");

            set_redraw_on_allocate(true);
            
            toolbar_box = new Widgets.ToolbarBox();
            toolbar_box.toolbar.close_window.connect((w) => {
                    quit();
                });
            
            workspace = new Widgets.Workspace();
            
            delete_event.connect((w) => {
                    quit();
                        
                    return true;
                });
            
            destroy.connect((t) => {
                    quit();
                });
            
            key_press_event.connect((w, e) => {
                    return on_key_press(w, e);
                });
            
            key_release_event.connect((w, e) => {
                    return on_key_release(w, e);
                });
            
            enter_notify_event.connect((w, e) => {
                    if (resize_timeout_source_id == null) {
                        resize_timeout_source_id = GLib.Timeout.add(resize_timeout_delay, () => {
                                int pointer_x, pointer_y;
                                Utils.get_pointer_position(out pointer_x, out pointer_y);
                                
                                if (pointer_x != resize_cache_x || pointer_y != resize_cache_y) {
                                    resize_cache_x = pointer_x;
                                    resize_cache_y = pointer_y;
                                    
                                    var cursor_type = get_cursor_type(pointer_x, pointer_y);
                                    var display = Gdk.Display.get_default();
                                    if (cursor_type != null) {
                                        get_window().set_cursor(new Gdk.Cursor.for_display(display, cursor_type));
                                    } else {
                                        get_window().set_cursor(null);
                                    }
                                }
                                
                                return true;
                            });
                    }
                        
                    return false;
                });
            
            leave_notify_event.connect((w, e) => {
                    if (resize_timeout_source_id != null) {
                        GLib.Source.remove(resize_timeout_source_id);
                        resize_timeout_source_id = null;
                    }
                    
                    if (reset_timeout_source_id == null) {
                        reset_timeout_source_id = GLib.Timeout.add(reset_timeout_delay, () => {
                                int pointer_x, pointer_y;
                                Utils.get_pointer_position(out pointer_x, out pointer_y);
                                
                                var cursor_type = get_cursor_type(pointer_x, pointer_y);
                                var display = Gdk.Display.get_default();
                                if (cursor_type != null) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, cursor_type));
                                } else {
                                    get_window().set_cursor(null);
                                }
                                
                                if (cursor_type == null) {
                                    GLib.Source.remove(reset_timeout_source_id);
                                    reset_timeout_source_id = null;
                                }
                            
                                return cursor_type != null;
                            });
                    }
                    
                    return false;
                });
            
            load_config();
            
            title_line_dark_color = Utils.hex_to_rgba("#000000", 0.3);
            title_line_light_color = Utils.hex_to_rgba("#000000", 0.1);
            
            transparent_window();
            set_decorated(false);
            
            window_frame_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            window_widget_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            
            add(window_frame_box);
            window_frame_box.pack_start(window_widget_box, true, true, 0);
            
            focus_in_event.connect((w) => {
                    update_style();
                    
                    return false;
                });
            
            focus_out_event.connect((w) => {
                    update_style();
                    remove_shortcut_viewer();
                    
                    return false;
                });
            
            configure_event.connect((w) => {
                    Cairo.RectangleInt rect;
                    get_window().get_frame_extents(out rect);
                    rect.x = 0;
                    rect.y = 0;
                    if (!window_is_fullscreen() && !window_is_max()) {
                        rect.x = window_frame_margin_start - Constant.RESPONSE_RADIUS;
                        rect.y = window_frame_margin_top - Constant.RESPONSE_RADIUS;
                        rect.width += - window_frame_margin_start - window_frame_margin_end + Constant.RESPONSE_RADIUS * 2;
                        rect.height += - window_frame_margin_top - window_frame_margin_bottom + Constant.RESPONSE_RADIUS * 2;
                    }

                    var shape = new Cairo.Region.rectangle(rect);
                    get_window().input_shape_combine_region(shape, 0, 0);
                    
                    int width, height;
                    get_size(out width, out height);

                    if (cache_width != width || cache_height != height) {
                        cache_width = width;
                        cache_height = height;
                    }
                    
                    return false;
                });
            
            window_state_event.connect((w, e) => {
                    toolbar_box.toolbar.update_max_button();
                    
                    update_style();
                    
                    if (window_is_fullscreen() || window_is_max()) {
                        window_widget_box.margin_top = 1;
                        window_widget_box.margin_bottom = 0;
                        window_widget_box.margin_start = 0;
                        window_widget_box.margin_end = 0;
                    } else if (window_is_tiled()) {
                        window_widget_box.margin_top = 1;
                        window_widget_box.margin_bottom = 1;
                        window_widget_box.margin_start = 1;
                        window_widget_box.margin_end = 1;
                    } else {
                        window_widget_box.margin_top = 2;
                        window_widget_box.margin_bottom = 2;
                        window_widget_box.margin_start = 2;
                        window_widget_box.margin_end = 2;
                    }

                    if (window_is_fullscreen() || window_is_max()) {
                        window_frame_box.margin_top = 0;
                        window_frame_box.margin_bottom = 0;
                        window_frame_box.margin_start = 0;
                        window_frame_box.margin_end = 0;
                        
                        get_window().set_shadow_width(0, 0, 0, 0);
                    } else {
                        window_frame_box.margin_top = window_frame_margin_top;
                        window_frame_box.margin_bottom = window_frame_margin_bottom;
                        window_frame_box.margin_start = window_frame_margin_start;
                        window_frame_box.margin_end = window_frame_margin_end;

                        get_window().set_shadow_width(window_frame_margin_start, window_frame_margin_end, window_frame_margin_top, window_frame_margin_bottom);
                    }
                    return false;
                });
            
            button_press_event.connect((w, e) => {
                    if (window_is_normal()) {
                        int pointer_x, pointer_y;
                        e.device.get_position(null, out pointer_x, out pointer_y);
                            
                        var cursor_type = get_cursor_type(e.x_root, e.y_root);
                        if (cursor_type != null) {
                            resize_window(this, pointer_x, pointer_y, (int) e.button, cursor_type);
                        }
                    }
                    
                    return false;
                });
            
            draw.connect_after((w, cr) => {
                    draw_window_below(cr);
                       
                    draw_window_widgets(cr);

                    draw_window_frame(cr);
                       
                    draw_window_above(cr);
                    
                    return true;
                });
            
            config.update.connect((w) => {
                    update_style();
                });
            
            int monitor = screen.get_monitor_at_window(screen.get_active_window());
            Gdk.Rectangle rect;
            screen.get_monitor_geometry(monitor, out rect);
            
            Gdk.Geometry geo = Gdk.Geometry();
            geo.min_width = rect.width / 3;
            geo.min_height = rect.height / 3;
            this.set_geometry_hints(null, geo, Gdk.WindowHints.MIN_SIZE);
            
            top_line_dark_color = Utils.hex_to_rgba("#000000", 0.2);
            top_line_light_color = Utils.hex_to_rgba("#ffffff", 0.2);
            
            window_frame_box.margin_top = window_frame_margin_top;
            window_frame_box.margin_bottom = window_frame_margin_bottom;
            window_frame_box.margin_start = window_frame_margin_start;
            window_frame_box.margin_end = window_frame_margin_end;
            
            window_widget_box.margin_top = 2;
            window_widget_box.margin_bottom = 2;
            window_widget_box.margin_start = 2;
            window_widget_box.margin_end = 2;
                        
            realize.connect((w) => {
                    try {
                        var width = config.config_file.get_integer("advanced", "window_width");
                        var height = config.config_file.get_integer("advanced", "window_height");
                        if (width == 0 || height == 0) {
                            set_default_size((int) (rect.width * window_default_scale), (int) (rect.height * window_default_scale));
                        } else {
                            set_default_size(width, height);
                        }
                    } catch (GLib.KeyFileError e) {
                        stdout.printf(e.message);
                    }
                });
            
            try{
                set_icon_from_file(Utils.get_image_path("deepin-designer.svg"));
            } catch(Error er) {
                stdout.printf(er.message);
            }
        }
        
        public void load_config() {
            config = new Config.Config();
            config.update.connect((w) => {
                    redraw_window();
                });
        }
            
        public void show_shortcut_viewer(int x, int y) {
            remove_shortcut_viewer();
            
            if (!is_show_shortcut_viewer) {
            }
        }
        
        public void remove_shortcut_viewer() {
            if (is_show_shortcut_viewer) {
                try {
                    GLib.AppInfo appinfo = GLib.AppInfo.create_from_commandline(
                        "deepin-shortcut-viewer -j=''",
                        null,
                        GLib.AppInfoCreateFlags.NONE);
                    appinfo.launch(null, null);
                } catch (Error e) {
                    print("Main on_key_press: %s\n", e.message);
                }
                    
                is_show_shortcut_viewer = false;
            }
        }
    	
        public void quit() {
            window_save_before_quit();
            Gtk.main_quit();
        }
        
        private bool on_key_press(Gtk.Widget widget, Gdk.EventKey key_event) {
            string keyname = Keymap.get_keyevent_name(key_event);
            
            if (keyname == "F11") {
                toggle_fullscreen();
                return true;
            }
                
            if (keyname == "F1") {
                Utils.show_manual();
                
                return true;
            }
            
            if (keyname == "Alt + r") {
                workspace.page_manager.focus_page.start_add_layout("Rectangle");
                
                return true;
            }
            
            if (keyname == "Alt + Shift + r") {
                workspace.page_manager.focus_page.start_add_layout("Rounded_Rectangle");
                
                return true;
            }

            if (keyname == "Alt + t") {
                workspace.page_manager.focus_page.start_add_layout("Triangle");
                
                return true;
            }

            if (keyname == "Alt + f") {
                workspace.page_manager.focus_page.start_add_layout("Five_Pointed_Star");
                
                return true;
            }
            
            if (keyname == "Alt + p") {
                workspace.page_manager.focus_page.start_add_layout("Pentagon");
                
                return true;
            }
            
            if (keyname == "Alt + o") {
                workspace.page_manager.focus_page.start_add_layout("Oval");
                
                return true;
            }
            
            if (keyname == "Alt + l") {
                workspace.page_manager.focus_page.start_add_layout("Line");
                
                return true;
            }
            
            if (keyname == "Alt + e") {
                workspace.page_manager.focus_page.start_add_layout("Pencil");
                
                return true;
            }
            
            if (keyname == "Esc") {
                workspace.page_manager.focus_page.cancel_add_layout();
            }
                
            return false;
        }

        private bool on_key_release(Gtk.Widget widget, Gdk.EventKey key_event) {
            if (Keymap.is_no_key_press(key_event)) {
                if (Utils.is_command_exist("deepin-shortcut-viewer")) {
                    remove_shortcut_viewer();
                }
            }
        
            return false;
        }
        
        public bool is_light_theme() {
            return config_theme_is_light;
        }
        
        public void toggle_fullscreen() {
            if (window_is_fullscreen()) {
                unfullscreen();
            } else {
                fullscreen();
            }
        }
        
        public void window_save_before_quit() {
            Cairo.RectangleInt rect;
            get_window().get_frame_extents(out rect);
                    
            if (window_is_normal()) {
                config.config_file.set_integer("advanced", "window_width", rect.width);
                config.config_file.set_integer("advanced", "window_height", rect.height);
                config.save();
            }
        }
        
        public Gdk.CursorType? get_cursor_type(double x, double y) {
            int window_x, window_y;
            get_window().get_origin(out window_x, out window_y);
                        
            int width, height;
            get_size(out width, out height);
            
            var left_side_start = window_x + window_frame_margin_start - Constant.RESPONSE_RADIUS;
            var left_side_end = window_x + window_frame_margin_start;
            var right_side_start = window_x + width - window_frame_margin_end;
            var right_side_end = window_x + width - window_frame_margin_end + Constant.RESPONSE_RADIUS;
            var top_side_start = window_y + window_frame_margin_top - Constant.RESPONSE_RADIUS;;
            var top_side_end = window_y + window_frame_margin_top;
            var bottom_side_start = window_y + height - window_frame_margin_bottom;
            var bottom_side_end = window_y + height - window_frame_margin_bottom + Constant.RESPONSE_RADIUS;
            
            if (x > left_side_start && x < left_side_end) {
                if (y > top_side_start && y < top_side_end) {
                    return Gdk.CursorType.TOP_LEFT_CORNER;
                } else if (y > bottom_side_start && y < bottom_side_end) {
                    return Gdk.CursorType.BOTTOM_LEFT_CORNER;
                }
            } else if (x > right_side_start && x < right_side_end) {
                if (y > top_side_start && y < top_side_end) {
                    return Gdk.CursorType.TOP_RIGHT_CORNER;
                } else if (y > bottom_side_start && y < bottom_side_end) {
                    return Gdk.CursorType.BOTTOM_RIGHT_CORNER;
                }
            }

            if (x > left_side_start && x < left_side_end) {
                if (y > top_side_end && y < bottom_side_start) {
                    return Gdk.CursorType.LEFT_SIDE;
                }
            } else if (x > right_side_start && x < right_side_end) {
                if (y > top_side_end && y < bottom_side_start) {
                    return Gdk.CursorType.RIGHT_SIDE;
                }
            } else {
                if (y > top_side_start && y < top_side_end) {
                    return Gdk.CursorType.TOP_SIDE;
                } else if (y > bottom_side_start && y < bottom_side_end) {
                    return Gdk.CursorType.BOTTOM_SIDE;
                }
            }
            
            return null;
        }
        
        public void redraw_window() {
            queue_draw();
        }
        
        public bool window_is_max() {
            return Gdk.WindowState.MAXIMIZED in get_window().get_state();
        }
        
        public bool window_is_tiled() {
            return Gdk.WindowState.TILED in get_window().get_state();
        }
        
        public bool window_is_fullscreen() {
            return Gdk.WindowState.FULLSCREEN in get_window().get_state();
        }
        
        public bool window_is_normal() {
            return !window_is_max() && !window_is_fullscreen() && !window_is_tiled();
        }

        public void update_style() {
            clean_style();
            
            bool is_light_theme = is_light_theme();
            
            if (is_active) {
                if (window_is_normal()) {
                    if (is_light_theme) {
                        window_frame_box.get_style_context().add_class("window_light_shadow_active");
                    } else {
                        window_frame_box.get_style_context().add_class("window_dark_shadow_active");
                    }
                } else {
                    window_frame_box.get_style_context().add_class("window_noradius_shadow_active");
                }
            } else {
                if (window_is_normal()) {
                    if (is_light_theme) {
                        window_frame_box.get_style_context().add_class("window_light_shadow_inactive");
                    } else {
                        window_frame_box.get_style_context().add_class("window_dark_shadow_inactive");
                    }
                } else {
                    window_frame_box.get_style_context().add_class("window_noradius_shadow_inactive");
                }
            }
        }
        
        public void clean_style() {
            window_frame_box.get_style_context().remove_class("window_light_shadow_inactive");
            window_frame_box.get_style_context().remove_class("window_dark_shadow_inactive");
            window_frame_box.get_style_context().remove_class("window_light_shadow_active");
            window_frame_box.get_style_context().remove_class("window_dark_shadow_active");
            window_frame_box.get_style_context().remove_class("window_noradius_shadow_inactive");
            window_frame_box.get_style_context().remove_class("window_noradius_shadow_active");
        }
        
        public void draw_window_widgets(Cairo.Context cr) {
            Utils.propagate_draw(this, cr);
        }
        
        public void add_widget(Gtk.Widget widget) {
            window_widget_box.pack_start(widget, true, true, 0);
        }

        public void toggle_max() {
            if (window_is_max()) {
                unmaximize();
            } else {
                maximize();
            }
        }
        
        public void draw_window_below(Cairo.Context cr) {
            
        }

        public void draw_window_frame(Cairo.Context cr) {
        }

        public void draw_window_above(Cairo.Context cr) {
        }

        public void transparent_window() {
            set_app_paintable(true); // set_app_paintable is neccessary step to make window transparent.
            Gdk.Screen screen = Gdk.Screen.get_default();
            set_visual(screen.get_rgba_visual());
        }
        
        public void show_window() {
            set_position(Gtk.WindowPosition.CENTER);
            
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.pack_start(toolbar_box, false, false, 0);
            box.pack_start(workspace, true, true, 0);
            
            add_widget(box);
            show_all();
        }
        
    }
}