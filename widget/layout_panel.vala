using Gtk;

namespace Widgets {
    public class LayoutPanel : Gtk.HBox {
        public int width = 240;
        public Gdk.RGBA frame_color;
        public Gdk.RGBA panel_color;
        
        public LayoutPanel() {
            set_size_request(width, -1);
            
            frame_color = Utils.hex_to_rgba("#303030", 0.1);
            panel_color = Utils.hex_to_rgba("#e6e6e6", 0.8);
            
            draw.connect(on_draw);
        }
        
        private bool on_draw(Gtk.Widget widget, Cairo.Context cr) {
            Gtk.Allocation rect;
            widget.get_allocation(out rect);
            
            var window = (Widgets.Window) get_toplevel();
            
            Utils.set_context_color(cr, panel_color);
            if (window.window_is_normal()) {
                Draw.draw_right_panel_rectangle(cr, 0, 0, rect.width, rect.height, 5);
            } else {
                Draw.draw_rectangle(cr, 0, 0, rect.width, rect.height);
            }
            
            Utils.set_context_color(cr, frame_color);
            Draw.draw_rectangle(cr, 0, 0, 1, rect.height);
            
            return true;
        }
    }
}