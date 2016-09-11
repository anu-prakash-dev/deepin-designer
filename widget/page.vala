using Gtk;

namespace Widgets {
    public class Page : Gtk.DrawingArea {
        public Gdk.RGBA background_color;
        public Gdk.RGBA drag_frame_color;
        public Gdk.RGBA drag_background_color;
        public Gdk.RGBA drag_layout_color;
        public LayoutManager layout_manager;
        public Layouts.Layout? focus_layout;
        public string? layout_type;
        public int? drag_start_x;
        public int? drag_start_y;
        public int? drag_x;
        public int? drag_y;
        
        public Page() {
            layout_manager = new Widgets.LayoutManager();
            background_color = Utils.hex_to_rgba("#f2f2f2", 1);
            drag_frame_color = Utils.hex_to_rgba("#303030", 0.1);
            drag_background_color = Utils.hex_to_rgba("#ff0000", 0.1);
            drag_layout_color = Utils.hex_to_rgba("#000000", 0.1);
            
            add_events(Gdk.EventMask.BUTTON_PRESS_MASK
                       | Gdk.EventMask.BUTTON_RELEASE_MASK
                       | Gdk.EventMask.POINTER_MOTION_MASK
                       | Gdk.EventMask.LEAVE_NOTIFY_MASK);
            
            button_press_event.connect((w, e) => {
                    drag_start_x = (int) e.x;
                    drag_start_y = (int) e.y;
                        
                    queue_draw();
                    
                    return false;
                });
            
            motion_notify_event.connect((w, e) => {
                    if (drag_start_y != null && drag_start_y != null) {
                        drag_x = (int) e.x;
                        drag_y = (int) e.y;
                        
                        queue_draw();
                    }
                    
                    return false;
                });
            
            button_release_event.connect((w, e) => {
                    if (layout_type != null) {
                        int draw_x = int.min(drag_start_x, drag_x);
                        int draw_y = int.min(drag_start_y, drag_y);
                        int draw_width = (int) Math.fabs(drag_start_x - drag_x);
                        int draw_height = (int) Math.fabs(drag_start_y - drag_y);
                        
                        focus_layout = layout_manager.add_layout(layout_type, draw_x, draw_y, draw_width, draw_height);
                        
                        layout_type = null;
                    }
                    
                    drag_start_x = null;
                    drag_start_y = null;
                    drag_x = null;
                    drag_y = null;
                        
                    queue_draw();
                    
                    reset_cursor();
                    
                    return false;
                });
            
            draw.connect(on_draw);
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
            } else {
                if (drag_start_x != null && drag_start_y != null && drag_x != null && drag_y != null) {
                    int draw_x = int.min(drag_start_x, drag_x);
                    int draw_y = int.min(drag_start_y, drag_y);
                    int draw_width = (int) Math.fabs(drag_start_x - drag_x);
                    int draw_height = (int) Math.fabs(drag_start_y - drag_y);
                    
                    Utils.set_context_color(cr, drag_layout_color);
                    Draw.draw_rectangle(cr, draw_x, draw_y, draw_width, draw_height, false);
                }
            }
            
            foreach (Layouts.Layout layout in layout_manager.layout_list) {
                layout.draw_layout(cr);
            }
            
            if (focus_layout != null) {
                focus_layout.draw_drag_frame(cr);
            }
            
            return true;
        }
        
        public void start_add_layout(string type) {
            layout_type = type;
            focus_layout = null;

            set_layout_cursor();
            
            queue_draw();
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