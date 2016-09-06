using Gtk;
using Layouts;

namespace Layouts {
    public class RectangleLayout : Layouts.Layout {
        public RectangleLayout() {
            
        }
        
        public void init(int init_x, int init_y, int init_width, int init_height) {
            x = init_x;
            y = init_y;
            width = init_width;
            height = init_height;
        }
        
        public override void draw_layout(Cairo.Context cr) {
            Utils.set_context_color(cr, background_color);
            Draw.draw_rectangle(cr, x + 1, y + 1, width - 2, height - 2);
            
            Utils.set_context_color(cr, frame_color);
            Draw.draw_rectangle(cr, x, y, width, height);
        }
    }
}