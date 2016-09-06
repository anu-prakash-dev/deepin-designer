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
        
        public virtual void draw_drag_dot(Cairo.Context cr) {
        }
    }
}