namespace Layouts {
    public class Layout {
        public int x;
        public int y;
        public int width;
        public int height;
        public Gdk.RGBA frame_color;
        public Gdk.RGBA background_color;
        public Gdk.RGBA drag_dot_frame_color;
        public Gdk.RGBA drag_dot_background_color;
        public int drag_dot_size = 6;
        
        public Layout() {
            frame_color = Utils.hex_to_rgba("#303030", 0.1);
            background_color = Utils.hex_to_rgba("#ff0000", 0.1);

            drag_dot_frame_color = Utils.hex_to_rgba("#000000", 0.5);
            drag_dot_background_color = Utils.hex_to_rgba("#333333", 0.1);
        }
        
        public virtual void draw_layout(Cairo.Context cr) {
            
        }
        
        public void draw_drag_frame(Cairo.Context cr) {
            // Top left drag dot.
            int drag_dot_x = x - drag_dot_size / 2;
            int drag_dot_y = y - drag_dot_size / 2;
                
            Utils.set_context_color(cr, drag_dot_background_color);
            Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
            Utils.set_context_color(cr, drag_dot_frame_color);
            Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

            // Top middle drag dot.
            draw_drag_dot(cr, x + width / 2 - drag_dot_size / 2, y - drag_dot_size / 2);
            
            // Top right drag dot.
            draw_drag_dot(cr, x + width - drag_dot_size / 2, y - drag_dot_size / 2);

            // Bottom left drag dot.
            draw_drag_dot(cr, x - drag_dot_size / 2, y + height - drag_dot_size / 2);
            
            // Bottom middle drag dot.
            draw_drag_dot(cr, x + width / 2 - drag_dot_size / 2, y + height - drag_dot_size / 2);
            
            // Bottom right drag dot.
            draw_drag_dot(cr, x + width - drag_dot_size / 2, y + height - drag_dot_size / 2);
            
            // Left drag dot.
            draw_drag_dot(cr, x - drag_dot_size / 2, y + height / 2 - drag_dot_size / 2);
            
            // Right drag dot.
            draw_drag_dot(cr, x + width - drag_dot_size / 2, y + height / 2 - drag_dot_size / 2);
        }
        
        public void draw_drag_dot(Cairo.Context cr, int x, int y) {
            Utils.set_context_color(cr, drag_dot_background_color);
            Draw.draw_rectangle(cr, x + 1, y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
            Utils.set_context_color(cr, drag_dot_frame_color);
            Draw.draw_rectangle(cr, x, y, drag_dot_size, drag_dot_size);
        }
    }
}