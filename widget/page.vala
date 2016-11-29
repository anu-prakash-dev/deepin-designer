using Gtk;
using Gee;

namespace Widgets {
    public class Page : Gtk.DrawingArea {
        public Gdk.RGBA background_color;
        public Gdk.RGBA drag_frame_color;
        public Gdk.RGBA drag_background_color;
        public LayoutManager layout_manager;
        public Layouts.Layout? focus_layout;
        public string? layout_type;
        public int? drag_start_x;
        public int? drag_start_y;
        public int? drag_start_save_x;
        public int? drag_start_save_y;
        public int? drag_x;
        public int? drag_y;
        public int? move_start_x;
        public int? move_start_y;
        public bool is_mouse_start_move = false;
        public bool is_layout_move_start = false;
        
        public Page() {
            layout_manager = new Widgets.LayoutManager();
            background_color = Utils.hex_to_rgba("#f2f2f2", 1);
            drag_frame_color = Utils.hex_to_rgba("#303030", 0.1);
            drag_background_color = Utils.hex_to_rgba("#ff0000", 0.1);
            
            add_events(Gdk.EventMask.BUTTON_PRESS_MASK
                       | Gdk.EventMask.BUTTON_RELEASE_MASK
                       | Gdk.EventMask.POINTER_MOTION_MASK
                       | Gdk.EventMask.LEAVE_NOTIFY_MASK);
            
            button_press_event.connect((w, e) => {
                    drag_start_x = (int) e.x;
                    drag_start_y = (int) e.y;
                    
                    if (layout_type == "Text") {
                        add_text_layout();
                    }
                        
                    queue_draw();
                    
                    return false;
                });
            
            motion_notify_event.connect((w, e) => {
                    if (drag_start_y != null && drag_start_y != null) {
                        drag_x = (int) e.x;
                        drag_y = (int) e.y;
                        
                        if (layout_type != null && layout_type != "Text" && layout_type != "Image") {
                            if (is_layout_move_start) {
                                create_move_shape_layout(drag_x, drag_y);
                            } else if (!is_mouse_start_move) {
                                add_shape_layout();
                            } else {
                                create_resize_shape_layout(drag_x, drag_y);
                            }
                            
                        }
                        
                        queue_draw();
                    }
                    
                    return false;
                });
            
            button_release_event.connect((w, e) => {
                    if (layout_type != null) {
                        layout_type = null;
                        
                        if (focus_layout != null) {
                            focus_layout.is_create_finish = true;
                            
                            if (focus_layout.get_type().is_a(typeof(Layouts.ShapeLayout))) {
                                ((Layouts.ShapeLayout) focus_layout).clean_move_save_data();
                            }
                        }
                    }
                    
                    drag_start_x = null;
                    drag_start_y = null;
                    drag_x = null;
                    drag_y = null;
                    
                    move_start_x = null;
                    move_start_y = null;
                    
                    queue_draw();
                    
                    reset_cursor();
                    is_mouse_start_move = false;
                    is_layout_move_start = false;
                    
                    return false;
                });
            
            draw.connect(on_draw);
        }
        
        public void handle_key_press(string keyname) {
            if (!is_layout_move_start && focus_layout != null && focus_layout.get_type().is_a(typeof(Layouts.ShapeLayout)) && keyname == "Space") {
                is_layout_move_start = true;
                
                drag_start_save_x = drag_start_x;
                drag_start_save_y = drag_start_y;
                
                move_start_x = drag_x;
                move_start_y = drag_y;
                
                ((Layouts.ShapeLayout) focus_layout).save_position();
            }
        }
        
        public void handle_key_release(Gdk.EventKey key_event) {
            if (Keymap.is_no_key_press(key_event)) {
                if (is_layout_move_start) {
                    is_layout_move_start = false;
                
                    drag_start_save_x = null;
                    drag_start_save_y = null;
                }
            }
        }
        
        private bool on_draw(Gtk.Widget widget, Cairo.Context cr) {
            Gtk.Allocation rect;
            widget.get_allocation(out rect);
            
            Utils.set_context_color(cr, background_color);
            Draw.draw_rectangle(cr, 0, 0, rect.width, rect.height);
            
            if (layout_type == null) {
                if (drag_start_x != null && drag_start_y != null && drag_x != null && drag_y != null) {
                    int draw_x = int.min(drag_start_x, drag_x);
                    int draw_y = int.min(drag_start_y, drag_y);
                    int draw_width = (int) Math.fabs(drag_start_x - drag_x);
                    int draw_height = (int) Math.fabs(drag_start_y - drag_y);
                    
                    Utils.set_context_color(cr, drag_background_color);
                    Draw.draw_rectangle(cr, draw_x + 1, draw_y + 1, draw_width - 2, draw_height - 2);
                    
                    Utils.set_context_color(cr, drag_frame_color);
                    Draw.draw_rectangle(cr, draw_x, draw_y, draw_width, draw_height, false);
                }
            }
            
            foreach (Layouts.Layout layout in layout_manager.layout_list) {
                layout.draw_layout(cr);
            }
            
            if (focus_layout != null) {
                if (focus_layout.is_create_finish) {
                    focus_layout.draw_drag_frame(cr);
                }
            }
            
            return true;
        }
        
        public void start_add_layout(string type) {
            layout_type = type;
            
            if (type == "Image") {
                add_image_layout();
            } else {
                focus_layout = null;

                set_layout_cursor();
            }
            queue_draw();
        }

        public void add_image_layout() {
            focus_layout = layout_manager.add_layout(layout_type);
            focus_layout.update_track(this, 30, 30, null, null);
        }
        
        public void add_text_layout() {
            focus_layout = layout_manager.add_layout(layout_type);
            focus_layout.update_track(this, drag_start_x, drag_start_y, null, null);
        }
        
        public void add_shape_layout() {
            if (drag_x != drag_start_x || drag_y != drag_start_y) {
                focus_layout = layout_manager.add_layout(layout_type);
                is_mouse_start_move = true;
            }
        }
        
        public void create_resize_shape_layout(int drag_x, int drag_y) {
            if (focus_layout != null) {
                focus_layout.update_track(this, drag_start_x, drag_start_y, drag_x, drag_y);
            }
        }
        
        public void create_move_shape_layout(int drag_x, int drag_y) {
            if (focus_layout != null && focus_layout.get_type().is_a(typeof(Layouts.ShapeLayout))) {
                ((Layouts.ShapeLayout) focus_layout).update_position(drag_x - move_start_x, drag_y - move_start_y);
                
                drag_start_x = drag_start_save_x + drag_x - move_start_x;
                drag_start_y = drag_start_save_y + drag_y - move_start_y;
            }
        }
        
        public void cancel_add_layout() {
            layout_type = null;
            reset_cursor();
        }
        
        public void set_layout_cursor() {
            var display = Gdk.Display.get_default();
            get_toplevel().get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.CROSSHAIR));
        }
        
        public void reset_cursor() {
            get_toplevel().get_window().set_cursor(null);
        }
    }
}